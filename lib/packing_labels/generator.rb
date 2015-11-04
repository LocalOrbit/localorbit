module PackingLabels
  class Generator
    class << self
      def generate(orders:,request:,product_labels_only:,product_label_format:,print_multiple_labels_per_item:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(orders:orders, host: request.base_url)
        # [ 
        #   { order_number: .... }
        #   { order_number: .... }
        #   { order_number: .... }
        # ]
        labels = PackingLabels::Label.make_labels(order_infos, product_labels_only, product_label_format, print_multiple_labels_per_item)
        # [
        #   { template: "...", data: { ... } }
        #   { template: "...", data: { ... } }
        # ]
        pages = PackingLabels::Page.make_pages(labels, product_label_format)
        # [ 
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        # ]

        if product_label_format == 4
          label_template = 'avery_labels/labels_4'
        elsif product_label_format == 16
          label_template = 'avery_labels/labels_16'
        end

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: label_template,
          pdf_settings: TemplatedPdfGenerator::ZeroMargins.merge(page_size: "letter"),
          locals: {
            params: {
              pages: pages
            }
          }
        )
      end
    end
  end
end