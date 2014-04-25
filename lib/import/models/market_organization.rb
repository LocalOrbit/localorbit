require 'import/models/base'
class Import::MarketOrganization < Import::Base
  self.table_name = "organizations_to_domains"
  self.primary_key = "otd_id"

  belongs_to :market, class_name: "Import::Market", foreign_key: "domain_id"
  belongs_to :organization, class_name: "Import::Organization", foreign_key: "org_id"
end
