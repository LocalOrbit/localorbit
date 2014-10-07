class GenerateInvoicePdf
  include Interactor

  def perform
    if context[:order].present? && order.invoiced? && !order.invoice_pdf.present?
      res = MakeInvoicePdfTempFile.perform(order:order)
      order.invoice_pdf = res.pdf
      fail!(message: "Unable to generate invoice PDF for this order.") unless order.save
      res.file.unlink
    end
  end
end
