class MarketDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def first_address
    addresses.first
  end

  def seller_locations_map
    addresses = organizations.selling.map do |seller|
      location = seller.locations.first
      URI::escape "#{location.address}, #{location.city} #{location.state}" if location
    end.compact

    "http://maps.google.com/maps/api/staticmap?size=400x400&markers=#{addresses.join('|')}&sensor=false&maptype=terrain&key=#{Figaro.env.google_maps_key}"
  end
end
