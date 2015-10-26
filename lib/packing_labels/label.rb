module PackingLabels
  class Label
    class << self

      def make_labels(order_infos, product_labels_only, product_label_format)
        order_infos.flat_map do |order_info|
          make_order_labels(order_info, product_labels_only, product_label_format, order_infos)
        end
      end

      def make_order_labels(order_info, product_labels_only, product_label_format, orders)

        if product_label_format == 4
          product_template = 'avery_labels/vertical_product_4'
          order_template = "avery_labels/vertical_order_4"
        elsif product_label_format == 10
          product_template = 'avery_labels/vertical_product_10'
          order_template = "avery_labels/vertical_order_10"
        elsif product_label_format == 16
          product_template = 'avery_labels/vertical_product_16'
          order_template = "avery_labels/vertical_order_16"
        end

        i = 0
        labels = []
        order = order_info.dup
        products = order.delete :products
        num_to_shift = product_label_format - (2+products.length)
        if product_labels_only != "true"
          labels << make_label(order_template, {order: order})
          labels << products.map{|product_info| make_label(product_template, {order: order, product: product_info}) }
          while i < num_to_shift do
            labels << page_break
            i = i + 1
          end
        else
          labels << products.map{|product_info| make_label(product_template, {order: order, product: product_info}) }
        end
        labels << reset_page
        labels.flatten
      end

      def make_label(template, info_object)
        {
          template: template,
          data: info_object
        }
      end

      def page_break
        {
            template: "avery_labels/page_break",
            data: nil
        }
      end
      def reset_page
        {
            template: "avery_labels/reset_page",
            data: nil
        }
      end
    end
  end
end

