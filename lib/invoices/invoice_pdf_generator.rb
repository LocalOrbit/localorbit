module Invoices
  class InvoicePdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)
        invoice = BuyerOrder.new(order)

        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/invoices/show",
          locals: {
            invoice: invoice,
            market: invoice.market.decorate,
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
