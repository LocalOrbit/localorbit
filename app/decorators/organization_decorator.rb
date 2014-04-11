class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def locations_map
    addresses = locations.visible.map do |location|
      URI.escape "#{location.address}, #{location.city} #{location.state}" if location
    end.compact

    "http://maps.google.com/maps/api/staticmap?size=340x300&markers=#{addresses.join('|')}&sensor=false&maptype=terrain&#{ locations.visible.count > 1 ? "" : "zoom=8&" }key=#{Figaro.env.google_maps_key}"
  end

  def ship_from_address
    address = shipping_location
    raw "#{address.address}<br/>#{address.city}, #{address.state} #{address.zip}"
  end

  def delivery_schedules
    markets.inject({}) do |result, market|
      result[market] = market.delivery_schedules.visible.order(:day)
      result
    end
  end

  def shipping_address
    shipping_location.address
  end

  def shipping_city_state_zip
    "#{shipping_location.city}, #{shipping_location.state} #{shipping_location.zip}"
  end

  def shipping_phone
    shipping_location.phone
  end
end
