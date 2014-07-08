require "import/models/base"
class Legacy::Category < Legacy::Base
  self.table_name = "categories"
  self.primary_key = "cat_id"
end
