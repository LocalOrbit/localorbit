class GenerateConsignmentInvoicePdf
  include Interactor

  def perform
    if context[:invoices].present?
      pdf_result = ConsignmentInvoices::ConsignmentInvoicePdfGenerator.generate_pdf(request: request, invoices: invoices)
      context[:invoice_pdf] = pdf_result.data
    end
  end
end
