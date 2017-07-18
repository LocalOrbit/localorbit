module Inventory
  class Utils
    class << self

      def check_sold_through(order)
        result = ActiveRecord::Base.connection.exec_query("
        SELECT coalesce(po.quantity,0) - coalesce(po_other.quantity,0) - coalesce(po_other2.quantity,0) - coalesce(so.quantity,0) AS quantity, so.net_price + po_other.net_price_other + po_other2.net_price_other AS balance_due
        FROM
          (SELECT sum(quantity) quantity
          FROM consignment_transactions
          WHERE order_id = $1
          AND transaction_type = 'PO' AND deleted_at IS NULL) po,
          (SELECT sum(ct.quantity) quantity, sum(ct.net_price * ct.quantity) net_price_other
          FROM consignment_transactions ct, consignment_transactions parent
          WHERE ct.id = parent.parent_id
          AND parent.order_id = $1
          AND ct.transaction_type != 'PO' AND ct.deleted_at IS NULL) po_other,
          (SELECT sum(ct.quantity) quantity, sum(ct.net_price * ct.quantity) net_price_other
          FROM consignment_transactions ct
          WHERE ct.order_id = $1
          AND (ct.transaction_type != 'PO') AND ct.deleted_at IS NULL) po_other2,
          (SELECT sum(so1.quantity) quantity, sum(so1.net_price * so1.quantity) net_price
          FROM consignment_transactions po1, consignment_transactions so1, orders o
          WHERE po1.id = so1.parent_id AND so1.order_id = o.id AND po1.order_id = $1
          AND so1.transaction_type = 'SO' AND so1.deleted_at IS NULL AND o.delivery_status='delivered') so", 'sold_through_query', [[nil,order.id]])

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

      def consignment_can_undeliver?(order)
        if order.sales_order?
          true
          #result = ActiveRecord::Base.connection.exec_query("
          #SELECT count(1) cnt FROM consignment_transactions
          #WHERE order_id = $1 AND transaction_type = 'SO'
          #", 'has_so_query', [[nil,order.id]])

          #Integer(result[0]['cnt']) == 0 ? true : false
        else
          result = ActiveRecord::Base.connection.exec_query("
          SELECT count(1) cnt
          FROM consignment_transactions ct, consignment_transactions ct2
          WHERE ct.id = ct2.parent_id
          AND ct.transaction_type = 'PO'
          AND ct.order_id = $1
          AND ct.deleted_at IS NULL AND ct2.deleted_at IS NULL", 'has_po_query', [[nil,order.id]])

          Integer(result[0]['cnt']) == 0 ? true : false
        end
      end

      def upsert_lot(product, lot_number, quantity, split_op = nil)
        lot = Lot.where("product_id = ? AND number = ? AND EXTRACT(YEAR FROM created_at) = ?", product.id, lot_number, Time.now.year.to_s).first
        if lot.present? && !quantity.nil?
          if split_op
            new_qty = lot.quantity + quantity
          else
            if lot.nil?
              new_qty = quantity
            else
              if quantity > lot.quantity
                new_qty = lot.quantity + (quantity - lot.quantity)
              elsif quantity < lot.quantity
                new_qty = lot.quantity - (lot.quantity - quantity)
              else
                new_qty = quantity
              end
            end
          end
          lot.update_attribute(:quantity, new_qty)
        else
          lot = Lot.create(
              product_id: product.id,
              number: lot_number,
              quantity: quantity
          )
        end

        lot
      end

      def generate_lot_number(order=nil)
        days = %w(A B C D E F G)
        current_time = Time.now.in_time_zone('Eastern Time (US & Canada)')

        weekday = days[current_time.wday]
        monthweek = (((current_time.mday - current_time.wday) - 1) / 7.0).ceil + 1

        "#{order.id}-#{weekday}#{monthweek}"
      end

      def qty_allocated(market_id, product_id, ct_id)
        o = OrderItem.joins("JOIN orders ON order_items.order_id = orders.id")
                .where("orders.market_id = ?", market_id)
                .where("order_items.product_id = ?", product_id)
                .where("order_items.po_ct_id = ?", ct_id)
                .where("orders.order_type = 'sales'")
                .sum("order_items.quantity_delivered")
        o.nil? ? 0 : o.to_i
      end

      def qty_committed(market_id, product_id, ct_id)
        o = OrderItem.joins("JOIN orders ON order_items.order_id = orders.id")
        .where("orders.market_id = ?", market_id)
        .where("order_items.product_id = ?", product_id)
        .where("order_items.po_ct_id = ?", ct_id)
        .where("orders.order_type = 'sales'")
        .where("order_items.delivery_status = 'pending'")
        .sum("order_items.quantity")
        o.nil? ? 0 : o.to_i
      end

      def qty_delivered(market_id, product_id, ct_id)
        o = OrderItem.joins("JOIN orders ON order_items.order_id = orders.id")
                .where("orders.market_id = ?", market_id)
                .where("order_items.product_id = ?", product_id)
                .where("order_items.po_ct_id = ?", ct_id)
                .where("orders.order_type = 'sales'")
                .where("order_items.delivery_status = 'delivered'")
                .sum("order_items.quantity_delivered")
        o.nil? ? 0 : o.to_i
      end

      def qty_awaiting_delivery(market_id, product_id)
        ct = ConsignmentTransaction
            .joins("JOIN orders ON consignment_transactions.order_id = orders.id")
            .where("orders.delivery_status = 'pending'
            AND consignment_transactions.transaction_type = 'PO'
            AND consignment_transactions.lot_id IS NULL
            AND consignment_transactions.deleted_at IS NULL
            AND consignment_transactions.market_id = ?
            AND consignment_transactions.product_id = ?", market_id, product_id)
            .select(:quantity).visible.first
        ct.nil? ? 0 : ct
      end

      def can_delete_order?(order)
        ct = ConsignmentTransaction.where(deleted_at: nil).where("order_id = ? AND transaction_type IN ('HOLDOVER','SHRINK','REPACK')", order.id).select(:id).visible.first
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
         .where(order_id: order.id, transaction_type: 'SO', deleted_at: nil)

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

      def get_supplier_net(order)
        ConsignmentTransaction.joins("
        JOIN consignment_transactions p ON p.id = consignment_transactions.parent_id
        JOIN products ON products.id = p.product_id
        JOIN organizations ON organizations.id = products.organization_id")
        .select("p.order_id, organizations.name, sum(consignment_transactions.quantity * consignment_transactions.net_price) AS amt, sum((consignment_transactions.sale_price * consignment_transactions.quantity) - (consignment_transactions.net_price * consignment_transactions.quantity)) AS profit")
        .where("consignment_transactions.order_id = ?", order.id)
        .where("consignment_transactions.transaction_type = 'SO'")
        .where(deleted_at: nil)
        .group("p.order_id, organizations.name")
      end

      def get_associated_po_item(order, item)
        ConsignmentTransaction.joins("JOIN consignment_transactions p ON p.parent_id = consignment_transactions.id")
        .where("p.product_id = ?", item.product.id)
        .where(deleted_at: nil)
        .where("p.order_id = ?", order.id).first
      end

      def load_parent_products(product_id)
        child_product = Product.find(product_id)
        Product.where(id: child_product.parent_product_id).select(:id, :general_product_id, :name, :unit_quantity).order(:name)
      end

      def validate_qty(item, order_type, market, organization, delivery)
        error = nil
        actual_count = nil
        product = Product.includes(:prices).find(item.product.id)
        if market.is_buysell_market? || (market.is_consignment_market? && order_type == 'sales' && item.lot_id > 0)
          delivery_date = delivery.deliver_on
          actual_count = product.available_inventory(delivery_date, market.id, organization.id, market.is_consignment_market? && order_type == 'sales' && item.lot_id > 0 ? item.lot_id : nil)
        elsif market.is_consignment_market? && order_type == 'sales' && item.lot_id == 0 # Checking consignment awaiting delivery item
          actual_count = ConsignmentTransaction.where(transaction_type: 'PO', product_id: item.product_id, lot_id: nil, deleted_at: nil).sum(:quantity)
        end
        if item.quantity && item.quantity > 0 && !actual_count.nil? && item.quantity > actual_count
          error = {
              item_id: item.id,
              error_msg: "Quantity of #{product.name} (#{product.unit.plural}) available for purchase: #{actual_count}",
              actual_count: actual_count
          }
        end
        error
      end
    end
  end
end
