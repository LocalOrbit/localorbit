require "import/models/base"
class Legacy::Timezone < Legacy::Base
  self.table_name = "timezones"
  self.primary_key = "tz_id"
end
