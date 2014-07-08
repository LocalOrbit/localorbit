require "import/models/base"
class Legacy::Background < Legacy::Base
  self.table_name = "backgrounds"
  self.primary_key = "background_id"

  has_many :brands, class_name: "Legacy::Brand", foreign_key: :branding_id
end
