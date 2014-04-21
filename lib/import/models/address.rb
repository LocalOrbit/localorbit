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
end
