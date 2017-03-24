module Inventory
  extend ActiveSupport::Concern

  def load_consignment_transactions(order)
    @child_transactions = []
    @po_transactions = ConsignmentTransaction.joins("
    LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
    LEFT JOIN products ON consignment_transactions.product_id = products.id
    LEFT JOIN order_items ON consignment_transactions.order_item_id = order_items.id")
   .where(order_id: order.id, transaction_type: 'PO')
   .where("parent_id IS NULL")
   .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.product_id, products.name as product_name, lots.number as lot_name, order_items.delivery_status, consignment_transactions.quantity, consignment_transactions.net_price, consignment_transactions.sale_price")
   .order("consignment_transactions.id, consignment_transactions.parent_id")

    if !@po_transactions.nil?
      @po_transactions.each do |po|
        ct = ConsignmentTransaction.joins("
      LEFT JOIN orders ON consignment_transactions.order_id = orders.id
      LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
      LEFT JOIN organizations ON orders.organization_id = organizations.id")
     .where(parent_id: po.id)
     .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.order_id, consignment_transactions.product_id, consignment_transactions.quantity, lots.number as lot_name, consignment_transactions.net_price, consignment_transactions.sale_price, organizations.name AS buyer_name, orders.delivery_status, consignment_transactions.holdover_order_id")
     .order("consignment_transactions.product_id, consignment_transactions.created_at")

        @child_transactions << ct.to_a
      end
    end

    @parent_transactions = []
    @so_transactions = ConsignmentTransaction.joins("
      LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
      LEFT JOIN products ON consignment_transactions.product_id = products.id
      LEFT JOIN order_items ON consignment_transactions.order_item_id = order_items.id")
     .where(order_id: order.id, transaction_type: 'SO')
     .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.product_id, products.name as product_name, lots.number as lot_name, lots.quantity as lot_quantity, order_items.delivery_status, consignment_transactions.quantity, consignment_transactions.net_price, consignment_transactions.sale_price, consignment_transactions.parent_id")
     .order("consignment_transactions.id, consignment_transactions.parent_id")


    if !@so_transactions.nil?
      @so_transactions.each do |so|
        ct = ConsignmentTransaction.joins("
          LEFT JOIN orders ON consignment_transactions.order_id = orders.id
          LEFT JOIN lots ON consignment_transactions.lot_id = lots.id
          LEFT JOIN organizations ON orders.organization_id = organizations.id")
         .where(id: so.parent_id)
         .select("consignment_transactions.id, consignment_transactions.transaction_type, consignment_transactions.order_id, consignment_transactions.product_id, consignment_transactions.quantity, lots.number as lot_name, consignment_transactions.net_price, consignment_transactions.sale_price, organizations.name AS buyer_name, orders.delivery_status")
         .order("consignment_transactions.product_id, consignment_transactions.created_at")

        @parent_transactions << ct.to_a
      end
    end
  end

  def load_open_po
    @open_po = Order.orders_for_seller(current_user).undelivered.where(order_type: 'purchase')
  end
end