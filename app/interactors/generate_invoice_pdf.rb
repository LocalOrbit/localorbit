class GenerateInvoicePdf
  include Interactor

  def perform
    if context[:order].present? && order.invoiced? && !order.invoice_pdf.present?
      # res = MakeInvoicePdfTempFile.perform(order:order)
      res = MakeInvoicePdfTempFile.perform(request: request, order: order)
      order.invoice_pdf = res.pdf
      order.invoice_pdf.name = res.document_name
      fail!(message: "Unable to generate invoice PDF for this order.") unless order.save
      res.file.unlink
    end
  end
end
