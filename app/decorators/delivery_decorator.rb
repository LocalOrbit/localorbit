class DeliveryDecorator < Draper::Decorator
  delegate_all

  def type
    buyer_pickup? ? "Pick Up:" : "Delivery:"
  end

  def display_date
    deliver_on.strftime("%B %e, %Y")
  end

  def checkout_date
    action = buyer_pickup? ? "Pickup on" : "Delivery on"
    "#{action} #{h.content_tag(:time, datetime: deliver_on) { display_date + ' ' + time_range}}"
  end

  def time_range
    if buyer_pickup?
      start_time = delivery_schedule.buyer_pickup_start
      end_time = delivery_schedule.buyer_pickup_end
    else
      start_time = delivery_schedule.seller_delivery_start
      end_time = delivery_schedule.seller_delivery_end
    end

    start_time.gsub!(" ", "")
    end_time.gsub!(" ", "")

    "between #{start_time} and #{end_time}"
  end

  def buyer_time_range
    if delivery_schedule.direct_to_customer?
      start_time = delivery_schedule.seller_delivery_start
      end_time   = delivery_schedule.seller_delivery_end
    else
      start_time = delivery_schedule.buyer_pickup_start
      end_time   = delivery_schedule.buyer_pickup_end
    end

    start_time.gsub!(" ", "")
    end_time.gsub!(" ", "")

    "between #{start_time} and #{end_time}"
  end

  def display_locations
    if buyer_pickup?
      [delivery_schedule.buyer_pickup_location]
    else
      context[:current_organization].locations.visible
    end
  end

  def buyer_pickup?
    delivery_schedule.buyer_pickup?
  end
end
