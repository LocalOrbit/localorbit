require "import/models/base"

module Imported
  class OrderItem < ActiveRecord::Base
    self.table_name = "order_items"

    belongs_to :order, class_name: "Imported::Order", inverse_of: :items
    belongs_to :product, class_name: "Imported::Product"
  end
end

module Legacy
  class DeliveryStatus < Legacy::Base
    self.table_name = "lo_delivery_statuses"
    self.primary_key = "ldstat_id"
  end

  class OrderItem < Legacy::Base
    self.table_name = "lo_order_line_item"
    self.primary_key = "lo_liid"

    belongs_to :delivery_status, class_name: "Legacy::DeliveryStatus", foreign_key: :ldstat_id
    belongs_to :delivery, class_name: "Legacy::Delivery", foreign_key: :lodeliv_id
    belongs_to :order, class_name: "Legacy::Order", foreign_key: :org_id

    def import
      attributes = {
        name: product_name,
        product: imported_product,
        seller_name: seller_name,
        delivery_status: imported_delivery_status,
        quantity: qty_ordered,
        quantity_delivered: qty_delivered,
        unit: unit,
        unit_price: unit_price,
        legacy_id: lo_liid
      }

      item = Imported::OrderItem.where(legacy_id: lo_liid).first
      if item.nil?
        puts "- Creating order item..."
        item = Imported::OrderItem.create(attributes)
      else
        puts "- Updating order item..."
        item.update(attributes)
      end

      item
    end

    def imported_product
      Imported::Product.where(legacy_id: prod_id).first
    end

    def imported_delivery_status
      delivery_status.try(:delivery_status) || "pending"
    end
  end
end
