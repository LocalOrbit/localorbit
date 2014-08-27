class Graticule::Geocoder::Canned
  class_attribute :next_response
  self.next_response = nil
  class_attribute :default

  def locate(address)
    response = next_response || LOCATIONS[address.to_s] || default
    self.next_response = nil
    response
  end
end

Geocode.geocoder = Graticule::Geocoder::Canned.new

unless defined?(LOCATIONS)
  LOCATIONS = {}
  [
    # name/query      locality        region country precision   latitude   longitude    postal_code
    ["San Francisco", "San Francisco", "CA", "US", :street,      37.775206, -122.419209, "94110"],
    ["Detroit",       "Detroit",       "MI", "US", :street,      42.3316,   -83.0475,    "48201"],
    ["49423",         "Holland",       "MI", "US", :postal_code, 42.767645, -86.109469,  "49423"],
  ].each do |row|
    LOCATIONS[row[0]] = Graticule::Location.new(locality: row[1], region: row[2], country: row[3],
                                                  precision: row[4], latitude: row[5], longitude: row[6],
                                                  postal_code: row[7])
  end
end

Geocode.geocoder.default = LOCATIONS["49423"]
