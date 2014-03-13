class DeliveryDecorator < Draper::Decorator
  delegate_all

  def type
    buyer_pickup? ? "Pick Up:" : "Delivery:"
  end

  def display_date
    deliver_on.strftime("%B %e, %Y")
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

    "Between #{start_time} and #{end_time}"
  end

  def display_locations
    if buyer_pickup?
      [delivery_schedule.buyer_pickup_location]
    else
      context[:current_organization].locations
    end
  end

  def buyer_pickup?
    delivery_schedule.buyer_pickup?
  end
end
