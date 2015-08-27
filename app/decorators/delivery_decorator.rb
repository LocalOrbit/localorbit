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
    direct_to_customer? ? "Customer" : "Market"
  end

  def seller_display_date
    deliver_on.strftime("%A %B %e, %Y")
  end
  alias_method :display_date, :seller_display_date

  def buyer_display_date
    if date = get_buyer_deliver_on
      date.strftime("%A %B %e, %Y") if date
    else
      nil
    end
  end

  def get_buyer_deliver_on
    buyer_deliver_on || deliver_on
  end

  def human_delivery_date
    "#{buyer_display_date} #{buyer_time_range}"
  end

  def checkout_date
    h.content_tag(:time, datetime: get_buyer_deliver_on.xmlschema) { human_delivery_date }
  end

  def display_cutoff_time
    cutoff_time.in_time_zone(delivery_schedule.market.timezone).strftime("%B %-d at %l%p")
  end

  def buyer_time_range
    if direct_to_customer?
      start_time = delivery_schedule.seller_delivery_start
      end_time   = delivery_schedule.seller_delivery_end
    else
      start_time = delivery_schedule.buyer_pickup_start
      end_time   = delivery_schedule.buyer_pickup_end
    end

    format_time_range(start_time, end_time)
  end

  def seller_time_range
    start_time = delivery_schedule.seller_delivery_start
    end_time   = delivery_schedule.seller_delivery_end

    format_time_range(start_time, end_time)
  end
  alias_method :fulfillment_time_range, :seller_time_range

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

  def direct_to_customer?
    delivery_schedule.direct_to_customer?
  end

  # Display methods for currently selected delivery

  def selected_type
    buyer_pickup? ? "Pick Up Date" : "Delivery Date"
  end

  # Display for upcoming delivery
  def upcoming_delivery_date_heading
    "#{seller_display_date} #{delivery_schedule.seller_delivery_start}"
  end

  def deliver_to_name
    delivery_schedule.seller_fulfillment_location.try(:name)
  end

  def deliver_to_location
    delivery_schedule.seller_fulfillment_address
  end

  def available_to_order?
    Time.current.end_of_minute < cutoff_time
  end

  def format_time_range(start_time, end_time)
    start_str = start_time.nil? ? "?" : start_time.gsub(" ", "")
    end_str = end_time.nil? ? "?" : end_time.gsub(" ", "")

    "between #{start_str} and #{end_str}"
  end

  def delivery_expired_notice
    "Ordering for your selected pickup or delivery date ended #{display_cutoff_time}. Please choose a different pickup or delivery date to continue shopping."
  end
end
