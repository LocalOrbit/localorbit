class Import::Organization < Import::Base
  self.table_name = "organizations"
  self.primary_key = "org_id"

  has_many :products, class_name: "Import::Product", foreign_key: "org_id"
  has_many :addresses, class_name: "Import::Address", foreign_key: "org_id"
end
