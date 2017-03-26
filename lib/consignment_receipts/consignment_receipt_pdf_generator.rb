module ConsignmentReceipts
  class ConsignmentReceiptPdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)
        receipt = BuyerOrder.new(order)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/consignment_receipts/show",
          locals: {
            receipt: receipt,
            market: receipt.market.decorate,
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
