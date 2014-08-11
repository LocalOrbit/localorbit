class DeliveryDecorator < Draper::Decorator
  delegate_all

  def type
    buyer_pickup? ? "Pick up:" : "Delivery:"
  end

  def cart_type
    buyer_pickup? ? "Pickup on" : "Delivery on"
  end

  def checkout_type
    buyer_pickup? ? "pickup on" : "delivery on"
  end

  def display_dropoff_location_type
    buyer_pickup? ? "Market" : "Customer"
  end

  def display_date
    deliver_on.strftime("%B %e, %Y")
  end

  def human_delivery_date
    "#{display_date} #{time_range}"
  end

  def checkout_date
    h.content_tag(:time, datetime: deliver_on.xmlschema) { human_delivery_date }
  end

  def time_range
    if buyer_pickup?
      start_time = delivery_schedule.buyer_pickup_start
      end_time = delivery_schedule.buyer_pickup_end
    else
      start_time = delivery_schedule.seller_delivery_start
      end_time = delivery_schedule.seller_delivery_end
    end

    format_time_range(start_time, end_time)
  end

  def buyer_time_range
    if delivery_schedule.direct_to_customer?
      start_time = delivery_schedule.seller_delivery_start
      end_time   = delivery_schedule.seller_delivery_end
    else
      start_time = delivery_schedule.buyer_pickup_start
      end_time   = delivery_schedule.buyer_pickup_end
    end

    format_time_range(start_time, end_time)
  end

  def fulfillment_time_range
    start_time = delivery_schedule.seller_delivery_start
    end_time   = delivery_schedule.seller_delivery_end

    format_time_range(start_time, end_time)
  end

  def buyer_time_range_capitalized
    buyer_time_range.sub("between", "Between")
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

  # Display methods for currently selected delivery

  def selected_type
    buyer_pickup? ? "Pick Up Date" : "Delivery Date"
  end

  # Display for upcoming delivery
  def upcoming_delivery_date_heading
    "#{display_date} #{delivery_schedule.seller_delivery_start}"
  end

  def deliver_to_name
    delivery_schedule.seller_fulfillment_location.try(:name)
  end

  def deliver_to_location
    delivery_schedule.seller_fulfillment_address
  end

  def available_to_order?
    Time.current < cutoff_time
  end

  def format_time_range(start_time, end_time)
    start_time.gsub!(" ", "")
    end_time.gsub!(" ", "")

    "between #{start_time} and #{end_time}"
  end
end
