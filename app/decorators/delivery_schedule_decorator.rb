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
    seller_fulfillment_location.present? ? "#{buyer_pickup_start} to #{buyer_pickup_end}" : "#{seller_delivery_start} to #{seller_delivery_end}"
  end

  def dropoff_time_window
    buyer_pickup? ? "#{buyer_pickup_start} to #{buyer_pickup_end}" : "#{seller_delivery_start} to #{seller_delivery_end}"
  end

  def seller_location_name
    if seller_fulfillment_location.present?
      "at #{seller_fulfillment_location.address} #{seller_fulfillment_location.city}, #{seller_fulfillment_location.state} #{seller_fulfillment_location.zip}"
    else
      "direct to customer"
    end
  end

  def location_name
    if buyer_pickup? && buyer_pickup_location.present?
      "at #{buyer_pickup_location.name}"
    else
      "direct to customer"
    end
  end

  def seller_human_description
    "from #{dropoff_time_window} #{seller_location_name}"
  end

  def attached_to_product(product)
    if product && product.persisted?
      product.delivery_schedule_ids.include?(id)
    else
      true
    end
  end

  def fulfillment_type
    if buyer_pickup?
      "Pick Up: #{seller_fulfillment_address}"
    elsif seller_fulfillment_location
      "Delivery: From Seller to Buyer"
    else
      "Delivery: From Market to Buyer"
    end
  end
end
