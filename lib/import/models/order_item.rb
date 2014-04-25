require 'import/models/base'

module Imported
  class OrderItem < ActiveRecord::Base
    self.table_name = "order_items"

    belongs_to :order, class_name: "Imported::Order", inverse_of: :items
  end
end

class Legacy::OrderItem < Legacy::Base
  self.table_name = "lo_order_line_item"
  self.primary_key = "lo_liid"

  belongs_to :order, class_name: "Legacy::Order", foreign_key: :org_id
end
