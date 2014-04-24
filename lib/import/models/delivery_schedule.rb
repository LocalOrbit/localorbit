require 'import/models/base'
class Import::DeliverySchedule < Import::Base
  self.table_name = "delivery_days"
  self.primary_key = "dd_id"

  belongs_to :market, class_name: "Import::Market", foreign_key: :domain_id

  def import(market)
    imported = ::DeliverySchedule.where(legacy_id: dd_id).first
    if imported.nil?
      imported = ::DeliverySchedule.new(
        legacy_id: dd_id,
        day: day_of_week,
        order_cutoff: hours_due_before,
        seller_fulfillment_location_id: fulfillment_location_id,
        seller_delivery_start: parse_time(delivery_start_time),
        seller_delivery_end: parse_time(delivery_end_time),
        buyer_pickup_location_id: pickup_location_id(market),
        buyer_pickup_start: parse_time(pickup_start_time),
        buyer_pickup_end: parse_time(pickup_end_time)
      )
    end
    imported
  end

  def day_of_week
    day_nbr > 6 ? 0 : day_nbr
  end

  def parse_time(value)
    (Time.parse("12:00AM -0000") + (60 * value).minutes).strftime("%_I:%M %p").strip
  end

  def fulfillment_location_id
    ::MarketAddress.where(legacy_id: deliv_address_id).first.try(:id) || 0
  end

  def pickup_location_id(market)
    pickup_address_id == 0 ? 0 : ::MarketAddress.where(legacy_id: pickup_address_id).first.try(:id)
  end

end
