module PackingLabels
  class Generator
    class << self
      def generate(delivery:,request:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(delivery, host: request.base_url)
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

        pdf_context = GeneratePdf.perform(
          request: request,
          template: "avery_labels/labels",
          pdf_size: { page_size: "letter" },
          params: {
            pages: pages
          })

        return pdf_context.pdf_result
      end
    end
  end
end
