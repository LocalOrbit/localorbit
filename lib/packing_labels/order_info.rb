module PackingLabels
  class OrderInfo
    class << self
      def make_order_infos(orders:, host:)
        orders.map {|order| make_order_info(order, host: host)}
      end

      def make_order_info(order, host:)
        market_logo_url = if(order.market.logo) then order.market.logo.url else nil end
        if(!order.delivery || !order.delivery.deliver_on)
          raise "No delivery date for order ##{order.id}."
          return nil
        end
        order_info = {
          id: order.id,
          deliver_on: order.delivery.deliver_on.strftime("%B %e, %Y"),
          order_number: order.order_number,
          buyer_name: order.organization.name,
          market_logo_url: market_logo_url,
          zpl_logo: order.market.zpl_logo,
          products: make_product_infos(order)
        }
      end

      def make_product_infos(order)
        order.items.sort_by(&:product_id).map { |order_item| make_product_info(order_item) }
      end

      def make_product_info(order_item)
        lot_desc = nil
        if order_item.lots.count > 0 && !order_item.product.use_simple_inventory
          lot_desc = "Lot #" + order_item.lots.collect(&:number).join(', ')
        end
        product_info = {
          product_name: order_item.name,
          unit_desc: order_item.unit,
          quantity: order_item.quantity,
          lot_desc: lot_desc.nil? ? '' : lot_desc,
          producer_name: order_item.seller_name,
          product_code: order_item.product.code
        }
      end
    end
  end
end

