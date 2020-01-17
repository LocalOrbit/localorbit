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
  def product_schedule_description(html: true)
    str = ""
    if html
      str += h.content_tag(:span, class: "weekday") { display_cycle }
    else
      str += display_cycle
    end
    str += " from #{seller_delivery_start} to #{seller_delivery_end}"
    if direct_to_customer?
      str += " direct to customer."
    else
      addr = seller_fulfillment_location
      str += " at #{addr.address} #{addr.city}, #{addr.state} #{addr.zip}."
      str += " For Buyer pick up/delivery #{buyer_weekday.pluralize} from #{buyer_pickup_start} to #{buyer_pickup_end}."
    end

    if html
      raw(str)
    else
      str
    end
  end

  def display_cycle
    if delivery_cycle == 'biweekly'
      "Bi-weekly, #{week_interval.ordinalize} #{seller_weekday}"
    elsif delivery_cycle == 'monthly_day'
      "Monthly (by Day), #{week_interval.ordinalize} #{seller_weekday}"
    elsif delivery_cycle == 'monthly_date'
      "Monthly (by Date), #{day_of_month.ordinalize} of each month"
    else
      "Weekly, #{seller_weekday}"
    end
  end
end
