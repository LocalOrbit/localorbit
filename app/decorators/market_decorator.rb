class MarketDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def first_address
    addresses.first
  end

  def seller_locations_map(w=400, h=400)
    addresses = organizations.selling.map do |seller|
      location = seller.shipping_location
      URI.escape "#{location.address}, #{location.city} #{location.state}" if location
    end.compact

    "http://maps.google.com/maps/api/staticmap?size=#{w}x#{h}&markers=#{addresses.join('|')}&sensor=false&maptype=terrain&key=#{Figaro.env.google_maps_key}"
  end

  def street_address
    first_address.address
  end

  def city_state_zip
    "#{first_address.city}, #{first_address.state} #{first_address.zip} "
  end

  def phone_number
    first_address.phone
  end

  def header
    if name.blank?
      changes[:name].first
    else
      name
    end
  end
end
