require 'import/models/base'
class Import::Address < Import::Base
  self.table_name = "addresses"
  self.primary_key = "address_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :region, class_name: "Import::Region", foreign_key: :region_id

  # 2-letter region/state code. Example: "MI"
  def region_code
    region.code
  end

  def import
    imported = ::MarketAddress.new(
      name: label,
      address: address,
      city: city,
      state: region_code,
      zip: zipcode,
      phone: telephone,
      fax: fax,
      deleted_at: is_deleted == 1 ? DateTime.current : nil
    )

    puts imported

    imported
  end

  def zipcode
    postal_code.present? ? postal_code : "00000"
  end
end
