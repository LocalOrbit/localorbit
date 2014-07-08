require "import/models/base"
class Legacy::Region < Legacy::Base
  self.table_name = "directory_country_region"
  self.primary_key = "region_id"
end
