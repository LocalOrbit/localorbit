require 'import/models/base'
class Location < ActiveRecord::Base
  belongs_to :organization, inverse_of: :locations
  acts_as_geocodable address: {street: :address, locality: :city, region: :state, postal_code: :zip}
end

class Import::Address < Import::Base
  self.table_name = "addresses"
  self.primary_key = "address_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :region, class_name: "Import::Region", foreign_key: :region_id

  # 2-letter region/state code. Example: "MI"
  def region_code
    region ? region.code : ""
  end

  def import
    imported = ::Location.where(legacy_id: address_id).first
    if imported.nil?
      imported = ::Location.new(
        legacy_id: address_id,
        name: label,
        address: address.gsub(";","\n"),
        city: city,
        state: region_code,
        zip: zipcode,
        phone: telephone,
        fax: fax,
        deleted_at: is_deleted == 1 ? DateTime.current : nil,
        default_billing: default_billing == 1,
        default_shipping: default_shipping == 1
      )
    end

    imported
  end

  def zipcode
    postal_code.present? ? postal_code : "00000"
  end
end
