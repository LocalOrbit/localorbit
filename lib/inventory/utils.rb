module Inventory
  class Utils
    class << self
      def validate_qty(item, market, organization, delivery)
        error = nil
        product = Product.includes(:prices).find(item.product.id)
        delivery_date = delivery.deliver_on
        actual_count = product.available_inventory(delivery_date, market.id, organization.id)

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
