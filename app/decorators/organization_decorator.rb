class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def locations_map
    addresses = locations.visible.map do |location|
      URI::escape "#{location.address}, #{location.city} #{location.state}" if location
    end.compact

    "http://maps.google.com/maps/api/staticmap?size=300x300&markers=#{addresses.join('|')}&sensor=false&maptype=terrain&key=#{Figaro.env.google_maps_key}"
  end
end
