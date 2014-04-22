require 'import/models/base'
class Import::Timezone < Import::Base
  self.table_name = "timezones"
  self.primary_key = "tz_id"
end
