class GenerateInvoicePdf
  include Interactor

  def perform
    # Setting pre_invoice to true gets us past the order.invoiced? check
    invoiced_ok = (context[:pre_invoice] == true) || order.invoiced?


    if context[:order].present? && invoiced_ok && !order.invoice_pdf.present?
      pdf_result = Invoices::InvoicePdfGenerator.generate_pdf(request: request, order: order)
      order.invoice_pdf = pdf_result.data
      order.invoice_pdf.name = "#{order.order_number}.pdf"
      fail!(message: "Unable to generate invoice PDF for this order.") unless order.save
    end
  end
end
