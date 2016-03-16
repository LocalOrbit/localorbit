module PackingLabels
  class Label
    class << self
      def make_labels(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item)
        order_infos.flat_map do |order_info|
          make_order_labels(order_info, product_labels_only, product_label_format, print_multiple_labels_per_item, order_infos)
        end
      end

      def make_order_labels(order_info, product_labels_only, product_label_format, print_multiple_labels_per_item, orders)

        if product_label_format == 1
          product_template = 'avery_labels/vertical_product_1'
          order_template = "avery_labels/vertical_order_1"
          print_multiple_labels_per_item = false # Override this for zebra labels to let the printer handle it
        elsif product_label_format == 4
          product_template = 'avery_labels/vertical_product_4'
          order_template = "avery_labels/vertical_order_4"
        elsif product_label_format == 16
          product_template = 'avery_labels/vertical_product_16'
          order_template = "avery_labels/vertical_order_16"
        end

        i = 0
        labels = []
        order = order_info.dup
        products = order.delete :products
        num_to_shift = product_label_format - (products.length)
        if product_labels_only != "true"
          labels << make_label(order_template, {order: order})
          i = add_product_labels(labels, order, products, product_template, i, print_multiple_labels_per_item)
          if product_label_format > 1
            while i < num_to_shift do
              labels << page_break
              i = i + 1
            end
            labels << reset_page
          end
        else
          add_product_labels(labels, order, products, product_template, i, print_multiple_labels_per_item)
        end
        labels.flatten
      end

      def add_product_labels(labels, order, products, product_template, c, print_multiple_labels_per_item)
        curr_count = c
        products.map do |product_info|
          j = 0
          k = 1
          if print_multiple_labels_per_item
            k = product_info[:quantity].round
          end
          while j < k
            labels << make_label(product_template, {order: order, product: product_info})
            j = j + 1
            curr_count = curr_count + 1
          end
        end
        return curr_count
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

