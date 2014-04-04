class OrderDecorator < Draper::Decorator
  delegate_all

  def display_delivery_or_pickup
    delivery.delivery_schedule.buyer_pickup? ? "can be picked up at:" : "will be delivered to:"
  end

  def display_delivery_address
    "#{delivery_address}, #{delivery_city}, #{delivery_state} #{delivery_zip}"
  end
end
