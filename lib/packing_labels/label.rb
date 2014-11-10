module PackingLabels
  class Label
    class << self
      def make_labels(order_infos)
        order_infos.map{|order_info| make_order_labels(order_info)}
      end

      def make_order_labels(order_info)
        labels = []
        products = order_info.delete :products
        labels << make_label(OrderTemplate, order_info)
        labels << products.map{|product_info| make_label(ProductTemplate, product_info) }
        labels
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

