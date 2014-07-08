require "import/models/base"
module Imported
  class MarketOrganization < ActiveRecord::Base
    belongs_to :market, class_name: "Imported::Market"
    belongs_to :organization, class_name: "Imported::Organization"
  end
end

class Legacy::MarketOrganization < Legacy::Base
  self.table_name = "organizations_to_domains"
  self.primary_key = "otd_id"

  belongs_to :market, class_name: "Legacy::Market", foreign_key: "domain_id"
  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: "org_id"
end
