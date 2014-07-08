require "import/models/base"

module Imported
  class Location < ActiveRecord::Base
    self.table_name = "locations"

    belongs_to :organization, class_name: "Imported::Organization", inverse_of: :locations
    acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}
  end
end

class Legacy::Address < Legacy::Base
  self.table_name = "addresses"
  self.primary_key = "address_id"

  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: :org_id
  belongs_to :region, class_name: "Legacy::Region", foreign_key: :region_id

  # 2-letter region/state code. Example: "MI"
  def region_code
    region ? region.code : ""
  end

  def import
    attributes = {
      legacy_id: address_id,
      name: imported_name,
      address: imported_address,
      city: imported_city,
      state: region_code,
      zip: zipcode,
      phone: telephone,
      fax: fax,
      deleted_at: is_deleted == 1 ? DateTime.current : nil,
      default_billing: default_billing == 1,
      default_shipping: default_shipping == 1
    }

    imported = Imported::Location.where(legacy_id: address_id).first
    if imported.nil?
      puts "- Creating organization address: #{label}"
      imported = Imported::Location.new(attributes)
    else
      puts "- Updating organization address: #{imported.name}"
      imported.update(attributes)
    end

    imported
  end

  def imported_name
    label.blank? ? "Default Location Name" : label
  end

  def imported_address
    address.blank? ? "TBD" : address.gsub(";", "\n")
  end

  def imported_city
    city.blank? ? "TBD" : city
  end

  def zipcode
    postal_code.present? ? postal_code : "00000"
  end
end
