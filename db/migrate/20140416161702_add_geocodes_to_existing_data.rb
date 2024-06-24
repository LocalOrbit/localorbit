class AddGeocodesToExistingData < ActiveRecord::Migration
  # class MarketAddress < ActiveRecord::Base
  #   acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}
  # end

  # class Location < ActiveRecord::Base
  #   acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}
  # end

  # class Geocoding < ActiveRecord::Base
  # end

  # def up
  #   MarketAddress.find_each do |address|
  #     address.save
  #   end

  #   Location.find_each do |location|
  #     location.save
  #   end

  #   # Fix geocodable_type
  #   Geocoding.where(geocodable_type: "AddGeocodesToExistingData::MarketAddress").update_all(geocodable_type: "MarketAddress")
  #   Geocoding.where(geocodable_type: "AddGeocodesToExistingData::Location").update_all(geocodable_type: "Location")
  # end

  # def down
  #   # nothing to do
  # end
end
