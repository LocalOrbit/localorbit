require 'import/models/base'
class Import::DeliverySchedule < Import::Base
  self.table_name = "delivery_days"
  self.primary_key = "dd_id"

  belongs_to :market, class_name: "Import::Market", foreign_key: :domain_id

  def import
    imported = ::DeliverySchedule.new(
      day: day_of_week,
      order_cutoff: hours_due_before,
      seller_delivery_start: delivery_start_time.strftime("%_I:%M %p").strip,
      seller_delivery_end: delivery_end_time.strftime("%_I:%M %p").strip,
      buyer_pickup_start: pickup_start_time.strftime("%_I:%M %p").strip,
      buyer_pickup_end: pickup_end_time.strftime("%_I:%M %p").strip
    )

    imported
  end

  def day_of_week
    day_nbr - 1
  end
end
