require 'import/models/base'
class Import::Product < Import::Base
  self.table_name = "products"
  self.primary_key = "prod_id"

  # belongs_to :market, class_name: "Import::Market"
  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :unit, class_name: "Import::Unit"
end
