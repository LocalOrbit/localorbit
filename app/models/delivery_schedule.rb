class DeliverySchedule < ActiveRecord::Base
  include SoftDelete

  WEEKDAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

  belongs_to :market, inverse_of: :delivery_schedules

  belongs_to :seller_fulfillment_location, class: MarketAddress
  belongs_to :buyer_pickup_location,       class: MarketAddress

  has_many :deliveries
  has_many :product_deliveries
  has_many :products, through: :product_deliveries

  validates :day,          presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 6,   allow_nil: true}
  validates :order_cutoff, presence: true, numericality: {greater_than_or_equal_to: 6, less_than_or_equal_to: 504, allow_nil: true}
  validates :seller_fulfillment_location_id, presence: true
  validates :seller_delivery_start,          presence: true
  validates :seller_delivery_end,            presence: true
  validates :buyer_pickup_location_id,       presence: true, unless: :direct_to_customer?
  validates :buyer_pickup_end,               presence: true, unless: :direct_to_customer?
  validates :buyer_pickup_start,             presence: true, unless: :direct_to_customer?

  validate :buyer_pickup_end_after_start,                      unless: :direct_to_customer?
  validate :buyer_pickup_start_after_seller_fulfillment_start, unless: :direct_to_customer?
  validate :seller_delivery_end_after_start

  def products_available_for_sale(organization, deliver_on_date=Time.current)
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

  def buyer_pickup?
    seller_fulfillment_location.present? && buyer_pickup_location.present?
  end

  def direct_to_customer?
    seller_fulfillment_location_id == 0
  end

  def seller_fulfillment_address
    if (address = seller_fulfillment_location)
      "#{address.address}, #{address.city}, #{address.state} #{address.zip}"
    else
      "Direct to customer"
    end
  end

  def weekday
    WEEKDAYS[day]
  end

  def next_delivery_date
    return @next_delivery_date if defined?(@next_delivery_date)

    Time.use_zone timezone do
      current_time = Time.current
      beginning = current_time.beginning_of_week(:sunday) - 1.week
      date = (beginning + day.days).to_date
      d = Time.zone.parse("#{date} #{seller_delivery_start}")
      d += 1.week while (d - order_cutoff.hours) < current_time

      return @next_delivery_date = d
    end
  end

  def timezone
    market.timezone || Time.zone
  end

  def next_delivery
    find_next_delivery || deliveries.create!(
      deliver_on: next_delivery_date,
      cutoff_time: next_order_cutoff_time
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
      (amount * ((fee || 0) / 100))
    else
      0.0
    end
  end

  protected

  def buyer_pickup_end_after_start
    validate_time_after(:buyer_pickup_end, buyer_pickup_end, buyer_pickup_start, "must be after buyer pickup start")
  end

  def buyer_pickup_start_after_seller_fulfillment_start
    validate_time_after(:buyer_pickup_start, buyer_pickup_start, seller_delivery_start, "must be after delivery start")
  end

  def seller_delivery_end_after_start
    validate_time_after(:seller_delivery_end, seller_delivery_end, seller_delivery_start, "must be after delivery start")
  end

  def validate_time_after(field, before, after, message)
    errors.add(field, message) if before && after && Time.parse(before) <= Time.parse(after)
  end
end
