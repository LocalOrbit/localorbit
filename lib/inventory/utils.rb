module Inventory
  class Utils
    class << self

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
            .select("quantity").first
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
            .select(:quantity).first
        ct.nil? ? 0 : ct
      end

    end
  end
end
