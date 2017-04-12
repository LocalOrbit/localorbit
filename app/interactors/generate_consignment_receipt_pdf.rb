class GenerateConsignmentReceiptPdf
  include Interactor

  def perform
    if context[:order].present?
      pdf_result = ConsignmentReceipts::ConsignmentReceiptPdfGenerator.generate_pdf(request: request, order: order, path: path)
      if !context[:path].present?
        printable.pdf = pdf_result.data
        printable.pdf.name = "receipt.pdf"
        printable.save!
      end
    end
  end
end
