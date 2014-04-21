class Import::User < Import::Base
  self.table_name = "customer_entity"
  self.primary_key = "entity_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
end
