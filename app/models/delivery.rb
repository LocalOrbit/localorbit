class Delivery < ActiveRecord::Base
  belongs_to :delivery_schedule
  has_many :orders, inverse_of: :delivery

  scope :upcoming, -> { where("deliveries.cutoff_time > ?", Time.current) }
  scope :future, -> { where("deliveries.deliver_on > ?", Time.current) }
  scope :with_orders, -> { joins(orders: {items: :product}).group("deliveries.id") }
  scope :with_orders_for_user, -> {|user| with_orders.where(products: {organization_id: user.organization_ids}) }

  def self.for_market(market)
    joins(:delivery_schedule).
    where(delivery_schedules: {market_id: market.id})
  end

  def self.for_seller(seller)
    joins(:delivery_schedule).
    where(delivery_schedules: {market_id: [seller.markets.map(&:id)]})
  end

  def self.upcoming_for_seller(seller)
    ids = Order.undelivered_orders_for_seller(seller).upcoming_delivery.pluck(:delivery_id).uniq
    where(id: ids)
  end

  def requires_location?
    !delivery_schedule.buyer_pickup?
  end
end
