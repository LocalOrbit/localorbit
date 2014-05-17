require 'import/models/base'

module Imported
  class OrderItem < ActiveRecord::Base
    self.table_name = "order_items"

    belongs_to :order, class_name: "Imported::Order", inverse_of: :items
    belongs_to :product, class_name: "Imported::Product"
  end
end

class Legacy::OrderItem < Legacy::Base
  self.table_name = "lo_order_line_item"
  self.primary_key = "lo_liid"

  has_one    :delivery_status, class_name: "Legacy::DeliveryStatus", foreign_key: :ldstat_id
  belongs_to :order, class_name: "Legacy::Order", foreign_key: :org_id

  def import
    item = Imported::OrderItem.where(legacy_id: lo_liid).first
    if item.nil?
      puts "- Creating order item..."
      item = Imported::OrderItem.create(
        name: product_name,
        product: imported_product,
        seller_name: seller_name,
        delivery_status: imported_delivery_status,
        quantity: qty_ordered,
        unit: unit,
        unit_price: unit_price,
        legacy_id: lo_liid
      )
    else
      puts "- Existing order item..."
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
