class GenerateConsignmentReceiptPdf
  include Interactor

  def perform
    if context[:order].present?
      pdf_result = ConsignmentReceipts::ConsignmentReceiptPdfGenerator.generate_pdf(request: request, order: order)
      order.receipt_pdf = pdf_result.data
      order.receipt_pdf.name = "receipt_#{order.order_number}.pdf"
      fail!(message: "Unable to generate consignment receipt PDF for this order.") unless order.save
    end
  end
end
