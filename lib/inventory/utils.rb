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
    end
  end
end
