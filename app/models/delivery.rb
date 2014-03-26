class Delivery < ActiveRecord::Base
  belongs_to :delivery_schedule

  scope :upcoming, lambda { where("deliveries.cutoff_time > ?", Time.current) }

  def self.for_market(market)
    joins(:delivery_schedule).
    where(delivery_schedules: {market_id: market.id})
  end

  def requires_location?
    !delivery_schedule.buyer_pickup?
  end
end
