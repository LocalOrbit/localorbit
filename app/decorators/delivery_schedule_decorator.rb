class DeliveryScheduleDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  # Used on Market page
  def pickup_or_dropoff
    if buyer_pickup?
      location = buyer_pickup_location
      "pickup at #{location.address}, #{location.city}, #{location.state} #{location.zip}"
    else
      "delivered direct to customer"
    end
  end

  # Used on Market page
  def buyer_time_window
    if direct_to_customer?
      "#{seller_delivery_start} to #{seller_delivery_end}"
    else
      "#{buyer_pickup_start} to #{buyer_pickup_end}"
    end
  end

  # Used by OrderItemDecorator
  def fulfillment_type
    if buyer_pickup?
      "Pick Up: #{seller_fulfillment_address}"
    elsif seller_fulfillment_location
      "Delivery: From Seller to Buyer"
    else
      "Delivery: From Market to Buyer"
    end
  end

  # Describes the seller and buyer time windows for listing on the Product editor.
  def product_schedule_description
    str = h.content_tag(:span, class: "weekday") { seller_weekday.pluralize }
    str += " from #{seller_delivery_start} to #{seller_delivery_end}"
    if direct_to_customer?
      str += " direct to customer."
    else
      addr = seller_fulfillment_location
      str += " at #{addr.address} #{addr.city}, #{addr.state} #{addr.zip}."
      str += " For Buyer pick up/delivery #{buyer_weekday.pluralize} from #{buyer_pickup_start} to #{buyer_pickup_end}."
    end
    
    str
  end

end
