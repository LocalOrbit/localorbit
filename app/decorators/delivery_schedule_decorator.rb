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
  def plural_weekday
    buyer_weekday + "s"
  end
  
  # Used on Market page
  def time_window
    if direct_to_customer?
      "#{seller_delivery_start} to #{seller_delivery_end}"
    else
      "#{buyer_pickup_start} to #{buyer_pickup_end}"
    end
  end

  # XXX?
  # def location_name
  #   if buyer_pickup? && buyer_pickup_location.present?
  #     "at #{buyer_pickup_location.name}"
  #   else
  #     "direct to customer"
  #   end
  # end

  # The implementation of dropoff_time_window appears to be incorrect.
  # Also, this method is only used from a/v/a/organizations/_delivery_schedules.html.erb, and I'm not sure that's even in use anymore.
  # XXX delete this bugger asap
  # def seller_human_description
  #   result = "from #{dropoff_time_window} #{seller_location_name}"
  #   if Rails.env.development? 
  #     File.open("HEY_LOOK_seller_human_description_WAS_CALLED_AFTER_ALL.txt", "wa") do |f|
  #       f.puts "DeliveryScheduleDecotor has in fact been called, returning '#{result}', called from:"
  #       f.puts caller
  #     end
  #   end
  #   return result
  # end
  #

  # XXX
  # def attached_to_product(product)
  #   if product && product.persisted?
  #     product.delivery_schedule_ids.include?(id)
  #   else
  #     true
  #   end
  # end

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

  private
  #XXX delete this bugger asap (only used by #seller_human_description)
  # def dropoff_time_window
  #   buyer_pickup? ? "#{buyer_pickup_start} to #{buyer_pickup_end}" : "#{seller_delivery_start} to #{seller_delivery_end}"
  # end

  #XXX delete this bugger asap (only used by #seller_human_description)
  # def seller_location_name
  #   if has_seller_fulfillment_location?
  #     "at #{seller_fulfillment_location.address} #{seller_fulfillment_location.city}, #{seller_fulfillment_location.state} #{seller_fulfillment_location.zip}"
  #   else
  #     "direct to customer"
  #   end
  # end

end
