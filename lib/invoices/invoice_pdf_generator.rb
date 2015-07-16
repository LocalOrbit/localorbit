module Invoices
  class InvoicePdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)
        TemplatedPdfGenerator.generate_pdf(
          request: request,
          template: "admin/invoices/show",
          locals: {
            invoice: BuyerOrder.new(order),
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
