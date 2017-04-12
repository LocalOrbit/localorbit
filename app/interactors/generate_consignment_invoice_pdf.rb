class GenerateConsignmentInvoicePdf
  include Interactor

  def perform
    if context[:invoices].present?
      pdf_result = ConsignmentInvoices::ConsignmentInvoicePdfGenerator.generate_pdf(request: request, invoices: invoices)
      printable.pdf = pdf_result.data
      printable.pdf.name = "invoice.pdf"
      printable.save!
    end
  end
end
