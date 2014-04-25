require 'import/models/base'
class Import::Unit < Import::Base
  self.table_name = "Unit"
  self.primary_key = "UNIT_ID"
end
