class GenerateConsignmentReceiptPdf
  include Interactor

  def perform
    if context[:orders].present?
      pdf_result = ConsignmentReceipts::ConsignmentReceiptPdfGenerator.generate_pdf(request: request, orders: orders)
      printable.pdf = pdf_result.data
      printable.pdf.name = "receipt.pdf"
      printable.save!
    end
  end
end
