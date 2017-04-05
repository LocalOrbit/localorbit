module ConsignmentReceipts
  class ConsignmentReceiptPdfGenerator
    class << self
      def generate_pdf(request:,orders:,path:nil)
        #receipt = BuyerOrder.new(order)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/consignment_receipts/show",
          locals: {
            receipts: orders,
            market: orders.first.market.decorate,
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
