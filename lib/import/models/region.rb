require 'import/models/base'
class Import::Region < Import::Base
  self.table_name = "directory_country_region"
  self.primary_key = "region_id"
end
