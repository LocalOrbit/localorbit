class ClearInvoicePdf
  include Interactor

  def perform
    if order
      order.update(invoice_pdf: nil)
    end
  end
end
