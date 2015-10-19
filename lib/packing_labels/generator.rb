module PackingLabels
  class Generator
    class << self
      def generate(orders:,request:,product_labels_only:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(orders:orders, host: request.base_url)
        # [ 
        #   { order_number: .... }
        #   { order_number: .... }
        #   { order_number: .... }
        # ]
        labels = PackingLabels::Label.make_labels(order_infos, product_labels_only)
        # [
        #   { template: "...", data: { ... } }
        #   { template: "...", data: { ... } }
        # ]
        pages = PackingLabels::Page.make_pages(labels, product_labels_only)
        # [ 
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        # ]

        if product_labels_only == "true"
          template = "avery_labels/labels"
        else
          template = "avery_labels/order_labels"
        end

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: template,
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