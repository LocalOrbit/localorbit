module PackingLabels
  class Generator
    class << self
      def generate(delivery:,request:)
        order_infos = PackingLabels::OrderInfo.make_order_infos(delivery)
        labels = PackingLabels::Label.make_labels(order_infos)
        pages = PackingLabels::Page.make_pages(labels)

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
