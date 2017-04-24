module ConsignmentInvoices
  class ConsignmentInvoicePdfGenerator
    class << self
      def generate_pdf(request:,order:,path:nil)

          TemplatedPdfGenerator.generate_pdf(
            request: request,
            template: "admin/consignment_invoices/show",
            locals: {
              invoice: order,
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
