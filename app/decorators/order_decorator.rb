class OrderDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def display_delivery_or_pickup
    delivery.delivery_schedule.buyer_pickup? ? "can be picked up at:" : "will be delivered to:"
  end

  def display_fulfillment_info
    delivery.delivery_schedule.buyer_pickup? ? "Buyer picks up from market on" : "Market delivers to buyer on"
  end

  def display_delivery_address
    "#{delivery_address}<br> #{delivery_city}, #{delivery_state} #{delivery_zip}".html_safe
  end

  def display_delivery_street
    delivery_address
  end

  def display_delivery_city_state_zip
    "#{delivery_city}, #{delivery_state} #{delivery_zip}"
  end

  def display_delivery_phone
    delivery_phone
  end

  def delivery_lat_long
    # address = organization.locations.default_shipping
    # if !address.nil? && !address.geocode.nil?
    #   raw "#{address.geocode.latitude},#{address.geocode.longitude}"
    # else
    #   ""
    # end
    ""
  end

  def display_market_street
    market_address.address if market_address
  end

  def display_market_city_state_zip
    "#{market_address.city}, #{market_address.state} #{market_address.zip}" if market_address
  end

  def display_market_phone
    market_address.phone if market_address
  end

  def market_address
    market.addresses.visible.first
  end

  def delivery_date
    delivery.deliver_on.strftime("%m/%d/%Y")
  end

  def note_indicator
    !notes.nil? && notes.length > 0 ? "<span class='tooltip--flag' data-tooltip='#{notes}'></span>".html_safe : ''
  end

  def display_payment_method
    if payment_method == 'po'
      'Purchase Order'
    else
      payment_method.titleize
    end
  end
end
