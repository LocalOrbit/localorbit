module PackingLabels
  class Generator
    class << self
      def generate(orders:,request:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(orders:orders, host: request.base_url)
        # [ 
        #   { order_number: .... }
        #   { order_number: .... }
        #   { order_number: .... }
        # ]
        labels = PackingLabels::Label.make_labels(order_infos)
        # [
        #   { template: "...", data: { ... } }
        #   { template: "...", data: { ... } }
        # ]
        pages = PackingLabels::Page.make_pages(labels)
        # [ 
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        #   {a: {label} b: {label} ... }
        # ]

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "avery_labels/labels",
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
