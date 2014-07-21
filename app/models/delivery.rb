class Delivery < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :delivery_schedule
  belongs_to :delivery_schedule
  has_many :orders, inverse_of: :delivery

  scope :upcoming, -> { where("deliveries.cutoff_time > ?", Time.current) }
  scope :future, -> { where("deliveries.deliver_on >= ?", Time.current.midnight) }
  scope :recent, -> { where(deliver_on: (4.weeks.ago..Time.current)) }
  scope :with_undelivered_orders, -> { joins(orders: {items: :product}).where(order_items: {delivery_status: "pending"}).group("deliveries.id") }
  scope :for_user, lambda {|user| joins(orders: {items: :product}).where(products: {organization_id: user.organization_ids}) }
  scope :active, -> { joins(:delivery_schedule).where(DeliverySchedule.visible_conditional) }

  def self.current_selected(market, id)
    return nil unless id
    active.for_market(market).find_by(id: id)
  end

  def self.for_market(market)
    joins(:delivery_schedule).
    where(delivery_schedules: {market_id: market.id})
  end

  def self.for_seller(seller)
    joins(:delivery_schedule).
    where(delivery_schedules: {market_id: [seller.markets.pluck(:id)]})
  end

  def products_available_for_sale(organization)
    delivery_schedule.products_available_for_sale(organization, deliver_on)
  end

  def requires_location?
    !delivery_schedule.buyer_pickup?
  end

  def can_accept_orders?
    cutoff_time > Time.current
  end
end
