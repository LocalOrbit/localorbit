class DeliveryDecorator < Draper::Decorator
  delegate_all

  def type
    is_pickup? ? "Pick Up:" : "Delivery:"
  end

  def display_date
    deliver_on.strftime("%B %e, %Y")
  end

  def time_range
    if is_pickup? 
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

  def location
    if is_pickup?
      delivery_schedule.buyer_pickup_location
    else
      context[:current_organization].shipping_location
    end
  end

  private

  def is_pickup?
    delivery_schedule.buyer_pickup_location.present?
  end
end
