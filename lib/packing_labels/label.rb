module PackingLabels
  class Label
    OrderTemplate = "avery_labels/order"
    ProductTemplate = "avery_labels/vertical_product"
    OrderProductTemplate = "avery_labels/vertical_order_product"
    class << self

      def make_labels(order_infos, product_labels_only)
        order_infos.flat_map{|order_info| make_order_labels(order_info, product_labels_only)}
      end

      def make_order_labels(order_info, product_labels_only)
        labels = []
        order = order_info.dup
        products = order.delete :products
        if product_labels_only != "true"
          labels << make_label(OrderTemplate, {order: order})
          labels << products.map{|product_info| make_label(OrderProductTemplate, {order: order, product: product_info}) }
        else
          labels << products.map{|product_info| make_label(ProductTemplate, {order: order, product: product_info}) }
        end
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

