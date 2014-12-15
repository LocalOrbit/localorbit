class GenerateInvoicePdf
  include Interactor

  def perform
    # Setting pre_invoice to true gets us past the order.invoiced? check
    invoiced_ok = (context[:pre_invoice] == true) || order.invoiced?

    if context[:order].present? && invoiced_ok && !order.invoice_pdf.present?
      # res = MakeInvoicePdfTempFile.perform(order:order)
      res = MakeInvoicePdfTempFile.perform(request: request, order: order)
      order.invoice_pdf = res.pdf
      order.invoice_pdf.name = res.document_name
      fail!(message: "Unable to generate invoice PDF for this order.") unless order.save
      res.file.unlink
    end
  end
end
