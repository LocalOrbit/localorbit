require 'import/models/base'
class Import::Market < Import::Base
  self.table_name = "domains"
  self.primary_key = "domain_id"

  has_many :organizations, class_name: "::Import::Organization"
end
