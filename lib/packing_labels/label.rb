module PackingLabels
  class Label
    OrderTemplate = "avery_labels/order"
    ProductTemplate = "avery_labels/vertical_product"
    class << self

      def make_labels(order_infos)
        order_infos.flat_map{|order_info| make_order_labels(order_info)}
      end

      def make_order_labels(order_info)
        labels = []
        order = order_info.dup
        products = order.delete :products
        labels << make_label(OrderTemplate, {order: order})
        labels << products.map{|product_info| make_label(ProductTemplate, {order: order, product: product_info}) }
        labels.flatten
      end

      def make_label(template, info_object)
        {
          template: template,
          data: info_object
        }
      end
    end
  end
end

