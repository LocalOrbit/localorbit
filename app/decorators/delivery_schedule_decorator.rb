class DeliveryScheduleDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def pickup_or_dropoff
    if buyer_pickup? && buyer_pickup_location.present?
      location = buyer_pickup_location
      "pickup at #{location.address}, #{location.city}, #{location.state} #{location.zip}"
    else
      "delivered direct to customer"
    end
  end

  def plural_weekday
    weekday + "s"
  end

  def time_window
    buyer_pickup? ? "#{buyer_pickup_start} to #{buyer_pickup_end}" : "#{seller_delivery_start} to #{seller_delivery_end}"
  end
end
