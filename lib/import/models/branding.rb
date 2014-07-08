require "import/models/base"
class Legacy::Brand < Legacy::Base
  self.table_name = "domains_branding"
  self.primary_key = "branding_id"

  belongs_to :market, class_name: "Legacy::Market", foreign_key: "domain_id"
  belongs_to :background, class_name: "Legacy::Background", foreign_key: :background_id
end
