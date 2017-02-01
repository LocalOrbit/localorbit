class DeliverySchedule < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  include SoftDelete
  NULL_ATTRS = %w( day_of_month week_interval )
  before_save :nil_if_blank

  WEEKDAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
  WEEKDAY_ABBREVIATIONS = %w(Su M Tu W Th F Sa)
  INTERVALS = {'weekly' => 1, 'biweekly' => 2, 'monthly_day' => 1, 'monthly_date' => 1, 'manual' => 0}

  WeekdayValidation = {presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 6,   allow_nil: true}}

  belongs_to :market, inverse_of: :delivery_schedules

  belongs_to :seller_fulfillment_location, class_name: MarketAddress
  belongs_to :buyer_pickup_location,       class_name: MarketAddress

  has_many :deliveries
  has_many :product_deliveries
  has_many :products, through: :product_deliveries


  validates :day,                            WeekdayValidation
  validates :buyer_day,                      WeekdayValidation
  validates :order_cutoff, presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 504, allow_nil: true}
  validates :seller_fulfillment_location_id, presence: true
  validates :seller_delivery_start,          presence: true
  validates :seller_delivery_end,            presence: true
  validates :buyer_pickup_location_id,       presence: true, unless: :direct_to_customer?
  validates :buyer_pickup_end,               presence: true, unless: :direct_to_customer?
  validates :buyer_pickup_start,             presence: true, unless: :direct_to_customer?

  validate :buyer_pickup_end_after_start,                      unless: :direct_to_customer?
  validate :seller_delivery_end_after_start
  validate :seller_day_and_buyer_day_are_same, if: :direct_to_customer?

  before_validation :ensure_days_are_set

  scope :active, -> { where('inactive_at IS NULL') }

  # used on Sales by Fulfillment report where OrderItems are filtered by type
  # (Seller to Buyer or Market to Buyer) or pickup location
  ransacker :fulfillment_type do |_|
    Arel.sql(<<-SQL
      CASE
        WHEN (delivery_schedules.seller_fulfillment_location_id != 0) AND (delivery_schedules.buyer_pickup_location_id = 0) THEN 'S2B'
        WHEN (delivery_schedules.seller_fulfillment_location_id = 0)  AND (delivery_schedules.buyer_pickup_location_id = 0) THEN 'M2B'
        ELSE delivery_schedules.buyer_pickup_location_id::TEXT
      END
    SQL
    )
  end

  def nil_if_blank
    NULL_ATTRS.each { |attr| self[attr] = nil if self[attr].blank? }
  end

  def products_available_for_sale(organization, deliver_on_date=Time.current.end_of_minute)
    participating_products.available_for_sale(market, organization, deliver_on_date)
  end

  def participating_products
    scope = if require_delivery? && require_cross_sell_delivery?
      Product
    elsif require_delivery?
      Product.joins("LEFT JOIN product_deliveries ON products.id = product_deliveries.product_id").
              where("(market_organizations.cross_sell_origin_market_id IS NULL) OR product_deliveries.delivery_schedule_id = :id", id: id)
    elsif require_cross_sell_delivery?
      Product.joins("LEFT JOIN product_deliveries ON products.id = product_deliveries.product_id").
              where("(market_organizations.cross_sell_origin_market_id IS NOT NULL) OR product_deliveries.delivery_schedule_id = :id", id: id)
    else
      products
    end
    scope.for_market_id(market_id)
  end

  def active?
    inactive_at == nil
  end

  def buyer_pickup?
    has_seller_fulfillment_location? and has_buyer_pickup_location?
  end

  def direct_to_customer?
    !has_seller_fulfillment_location?
  end

  def hub_to_customer?
    has_seller_fulfillment_location? and !has_buyer_pickup_location?
  end

  def has_seller_fulfillment_location?
    seller_fulfillment_location_id != nil and seller_fulfillment_location_id != 0
  end

  def has_buyer_pickup_location?
    buyer_pickup_location_id != nil and buyer_pickup_location_id != 0
  end

  def seller_fulfillment_address
    if (address = seller_fulfillment_location)
      "#{address.address}, #{address.city}, #{address.state} #{address.zip}"
    else
      "Direct to customer"
    end
  end

  def weekday
    seller_weekday
  end

  def seller_weekday
    WEEKDAYS[day]
  end

  def buyer_weekday
    WEEKDAYS[buyer_day]
  end

  def next_delivery_date
    interval = INTERVALS[delivery_cycle]
    @next_delivery_date ||= calc_next_delivery_date(interval)
  end

  def next_buyer_delivery_date
    interval = INTERVALS[delivery_cycle]
    @next_buyer_delivery_date ||= calc_next_buyer_delivery_date(next_delivery_date, interval)
  end

  def timezone
    market.timezone || Time.zone
  end

  def next_delivery
    if delivery_cycle != "manual"
      delivery = find_next_delivery
      unless delivery
        delivery = deliveries.create!(
          deliver_on: next_delivery_date,
          buyer_deliver_on: next_buyer_delivery_date,
          cutoff_time: next_order_cutoff_time
        )
      end
      delivery
    else
      nil
    end
  end

  def next_delivery_for_date(date)
    deliveries.create!(
      deliver_on: date.change(hour:17,min:0,sec:0),
      buyer_deliver_on: date.change(hour:6,min:0,sec:0),
      cutoff_time: date.change(hour:3,min:0,sec:0)
    )
  end

  def find_next_delivery
    deliveries.find_by(deliver_on: next_delivery_date)
  end

  def next_order_cutoff_time
    next_delivery_date - order_cutoff.hours
  end

  def free_delivery?
    (fee_type == "fixed" && fee == 0) || fee.nil?
  end

  def required?(organization)
    (require_delivery? && organization.market_organizations.not_cross_selling.where(market_id: market_id).exists?) ||
    (require_cross_sell_delivery? && organization.market_organizations.cross_selling.where(market_id: market_id).exists?)
  end

  def fees_for_amount(amount)
    case fee_type
    when "fixed"
      fee || 0
    when "percent"
      amount * ((fee || 0) / 100)
    else
      0.0
    end
  end

  protected

  def buyer_pickup_end_after_start
    validate_time_after(:buyer_pickup_end, buyer_pickup_end, buyer_pickup_start, "must be after buyer pickup start")
  end

  def seller_delivery_end_after_start
    validate_time_after(:seller_delivery_end, seller_delivery_end, seller_delivery_start, "must be after delivery start")
  end

  def validate_time_after(field, before, after, message)
    errors.add(field, message) if before && after && Time.parse(before) <= Time.parse(after)
  end

  def seller_day_and_buyer_day_are_same
    if day != buyer_day
      errors.add(:day, "must match Day when fulfillment method is Direct to Customer")
    end
  end

  def ensure_days_are_set
    if day and buyer_day.nil?
      self.buyer_day = day
    elsif buyer_day and day.nil?
      self.day = buyer_day
    end
  end

  # day, seller_delivery_start
  def calc_next_delivery_date(interval)
    Time.use_zone timezone do
      current_time = Time.current.end_of_minute
      case delivery_cycle
        when 'weekly','biweekly'
          beginning = current_time.beginning_of_week(:sunday) - interval.week
          date = (beginning + week_interval.week + day.days).to_date
          d = Time.zone.parse("#{date} #{seller_delivery_start}")
          d += interval.week while (d - self.order_cutoff.hours) < current_time
        when 'monthly_day'
          first_day = current_time.beginning_of_month.to_date
          arr = (first_day..(first_day.end_of_month)).to_a.select {|d| d.wday == day }
          date = week_interval == 'last' ? arr.last : arr[week_interval-1]
          d = Time.zone.parse("#{date} #{seller_delivery_start}")
          if d < current_time
            d += 1.month + day.days
          end
        when 'monthly_date'
          date = current_time.beginning_of_month.to_date + day_of_month.days - 1.days
          d = Time.zone.parse("#{date} #{seller_delivery_start}")
          if d < current_time
            d += 1.month
          end
        else
          nil
      end
      d
    end
  end

  def calc_next_buyer_delivery_date(delivery_time, interval)
    time_of_day = if buyer_pickup_start.present? and !direct_to_customer?
                    buyer_pickup_start
                  else
                    seller_delivery_start
                  end

    Time.use_zone timezone do
      current_time = Time.current.end_of_minute
      case delivery_cycle
        when 'weekly','biweekly'
          beginning = current_time.beginning_of_week(:sunday) - interval.week
          date = (beginning + week_interval.week + buyer_day.days).to_date
          d = Time.zone.parse("#{date} #{time_of_day}")
          d += interval.week while d < delivery_time
        when 'monthly_day'
          first_day = current_time.beginning_of_month.to_date
          arr = (first_day..(first_day.end_of_month)).to_a.select {|d| d.wday == day }
          date = week_interval == 'last' ? arr.last : arr[week_interval-1]
          d = Time.zone.parse("#{date} #{time_of_day}")
          if d < current_time
            d += 1.month + day.days
          end
        when 'monthly_date'
          date = current_time.beginning_of_month.to_date + day_of_month.days - 1.days
          d = Time.zone.parse("#{date} #{time_of_day}")
          if d < current_time
            d += 1.month
          end
        else
          nil
      end
      d
    end

=begin
    Time.use_zone timezone do
      current_time = Time.current.end_of_minute
      beginning = (interval_type == :week ? current_time.beginning_of_week(:sunday) : current_time.beginning_of_month) - interval.send(interval_type)
      if !day_of_month.nil? && day_of_month > 0
        this_month_date = beginning + 1.months + day_of_month.days - 1.days
        next_month_date = beginning + 2.months + day_of_month.days - 1.days
        date = (this_month_date < current_time ? next_month_date : this_month_date).to_date
        d = Time.zone.parse("#{date} #{time_of_day}")
      else
        date = (beginning + (week_interval.nil? ? 0 : interval.week) + buyer_day.days).to_date
        d = Time.zone.parse("#{date} #{time_of_day}")
        d += interval.week while d < delivery_time
      end
      return d
    end
=end
  end

end
