require "import/models/base"
class Legacy::OrderAddress < Legacy::Base
  self.table_name = "lo_order_address"
  self.primary_key = "lo_aid"

  belongs_to :order, class_name: "Legacy::Order", foreign_key: :org_id
  belongs_to :region, class_name: "Legacy::Region", foreign_key: :region_id
end
