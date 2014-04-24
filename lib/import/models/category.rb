require 'import/models/base'
class Import::Category < Import::Base
  self.table_name = "categories"
  self.primary_key = "cat_id"
end
