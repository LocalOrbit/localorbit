class GenerateConsignmentInvoicePdf
  include Interactor

  def perform
    if context[:invoice].present?
      pdf_result = ConsignmentInvoices::ConsignmentInvoicePdfGenerator.generate_pdf(request: request, invoice: invoice, path: path)
      if !context[:path].present?
        printable.pdf = pdf_result.data
        printable.pdf.name = "invoice.pdf"
        printable.save!
      end
    end
  end
end
