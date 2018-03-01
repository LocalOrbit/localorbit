module ConsignmentPickLists
  class ConsignmentPickListPdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/consignment_pick_lists/show",
          locals: {
            order: order,
            market: order.market.decorate,
            user: nil
          },
          pdf_settings: {
            page_size: "letter",
            print_media_type: true
          },
          path: path
        )
      end
    end
  end
end
