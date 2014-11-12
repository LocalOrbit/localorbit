module PackingLabels
  class OrderInfo
    class << self
      def make_order_infos(delivery, host:)
        delivery.orders.map {|order| make_order_info(order, host: host)}
      end

      def make_order_info(order, host:)
        market_logo_url = if(order.market.logo) then order.market.logo.url else nil end
        if(!order.delivery || !order.delivery.deliver_on)
          raise "No delivery date for order ##{order.id}."
          return nil
        end
        order_info = {
          deliver_on: order.delivery.deliver_on.strftime("%B %e, %Y"),
          order_number: order.order_number,
          buyer_name: order.organization.name,
          market_logo_url: market_logo_url,
          qr_code_url: PackingLabels::QrCode.make_qr_code(order, host: host),
          products: make_product_infos(order)
        }
      end

      def make_product_infos(order)
        order.items.sort_by(&:product_id).map { |order_item| make_product_info(order_item) }
      end

      def make_product_info(order_item)
        lot = order_item.lots.first
        lot_desc = if(lot) then "Lot ##{lot.lot_id}" else nil end
        product_info = {
          product_name: order_item.name,
          unit_desc: order_item.unit,
          quantity: order_item.quantity,
          lot_desc: lot_desc,
          producer_name: order_item.seller_name
        }
      end
    end
  end
end

