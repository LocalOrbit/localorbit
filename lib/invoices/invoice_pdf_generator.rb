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
            user: nil,
            header_params: header_params(invoice)
          },
          pdf_settings: { 
            page_size: "letter", 
            print_media_type: true
          },
          path: path
        )
      end

      def header_params(invoice)
        market  = invoice.market.decorate
        Invoices::InvoiceHeaderParamsGenerator.generate_header_params(invoice, market)
      end
    end
  end
end
