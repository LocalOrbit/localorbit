module Inventory
  class Utils
    class << self

      def check_sold_through(order)
        result = ActiveRecord::Base.connection.exec_query("
        SELECT coalesce(po.quantity,0) - coalesce(po_other.quantity,0) - coalesce(so.quantity,0) AS quantity, so.net_price + po_other.net_price_other AS balance_due
        FROM
          (SELECT sum(quantity) quantity
          FROM consignment_transactions
          WHERE order_id = $1
          AND transaction_type = 'PO' AND deleted_at IS NULL) po,
          (SELECT sum(quantity) quantity, sum(net_price * quantity) net_price_other
          FROM consignment_transactions
          WHERE order_id = $1
          AND transaction_type != 'PO' AND deleted_at IS NULL) po_other,
          (SELECT sum(so1.quantity) quantity, sum(so1.net_price * so1.quantity) net_price
          FROM consignment_transactions po1, consignment_transactions so1
          WHERE po1.id = so1.parent_id AND po1.order_id = $1
          AND so1.transaction_type = 'SO' AND so1.deleted_at IS NULL) so", 'sold_through_query', [[nil,order.id]])

        if Integer(result[0]['quantity']) == 0
          order.sold_through = true
        else
          order.sold_through = false
        end

        if !result[0]['balance_due'].nil? && Float(result[0]['balance_due']) > 0
          order.total_cost = Float(result[0]['balance_due'])
        end

        order.save
      end

      def upsert_lot(product, lot_number, quantity, split_op = nil)
        lot = Lot.where("product_id = ? AND number = ? AND EXTRACT(YEAR FROM created_at) = ?", product.id, lot_number, Time.now.year.to_s).first
        if lot.present?
          if split_op
            quantity = lot.quantity + quantity
          end
          lot.update_attribute(:quantity, quantity)
        else
          lot = Lot.create(
              product_id: product.id,
              number: lot_number,
              quantity: quantity
          )
        end

        lot
      end

      def generate_lot_number
        days = %w(A B C D E F G)
        current_time = Time.now

        weekday = days[current_time.wday]
        monthweek = (current_time.mday / 7.0).ceil

        "#{weekday}#{monthweek}"
      end

      def qty_committed(market_id, product_id)
        o = ConsignmentTransaction
            .where(market_id: market_id, product_id: product_id, transaction_type: 'SO', lot_id: nil)
            .select("quantity").visible.first
        o.nil? ? 0 : o.quantity
      end

      def qty_awaiting_delivery(market_id, product_id)
        ct = ConsignmentTransaction
            .joins("JOIN orders ON consignment_transactions.order_id = orders.id")
            .where("orders.delivery_status = 'pending'
            AND consignment_transactions.transaction_type = 'PO'
            AND consignment_transactions.lot_id IS NULL
            AND consignment_transactions.market_id = ?
            AND consignment_transactions.product_id = ?", market_id, product_id)
            .select(:quantity).visible.first
        ct.nil? ? 0 : ct
      end

      def can_delete_order?(order)
        ct = ConsignmentTransaction.where("order_id = ? AND transaction_type IN ('HOLDOVER','SHRINK','REPACK')", order.id).select(:id).visible.first
        ct.nil? ? true : false
      end

      def remove_po(order)
        ct = get_transaction_chain(order)
        ct.each do |trans|
          if trans['transaction_type'] == 'SO'
            so = Order.find(trans['order_id'])
            remove_so(so)
          elsif trans['transaction_type'] == 'PO'
            po = Order.find(trans['order_id'])
            po.items.each do |item|
              item.destroy
            end
            po.soft_delete
          end
          po_ct = ConsignmentTransaction.find(trans['id'])
          po_ct.soft_delete
        end
      end

      def remove_so(order)
        ct = ConsignmentTransaction
         .where(order_id: order.id, transaction_type: 'SO')

        order.items.each do |item|
          item.destroy
        end
        order.soft_delete

        ct.soft_delete
      end

      def get_transaction_chain(order)
        result = ActiveRecord::Base.connection.exec_query("
        WITH RECURSIVE consignment_trans AS (
        SELECT id, order_id, transaction_type, created_at
        FROM consignment_transactions
        WHERE order_id = $1
        UNION
        SELECT c.id, c.order_id, c.transaction_type, c.created_at
        FROM consignment_transactions c
          JOIN consignment_transactions p ON c.parent_id = p.id
        WHERE p.order_id = $1
        )
        SELECT id, order_id, transaction_type
        FROM consignment_trans
        ORDER BY created_at desc",'transaction_chain', [[nil,order.id]])

        result
      end

      def get_associated_po_item(order, item)
        ConsignmentTransaction.joins("JOIN consignment_transactions p ON p.parent_id = consignment_transactions.id")
        .where("p.product_id = ?", item.product.id)
        .where("p.order_id = ?", order.id).first
      end

      def load_parent_products(product_id)
        child_product = Product.find(product_id)
        Product.where(id: child_product.parent_product_id).select(:id, :general_product_id, :name, :unit_quantity).order(:name)
      end

    end
  end
end
