class ClearConsignmentReceiptPdf
  include Interactor

  def perform
    if order
      order.update(receipt_pdf: nil)
    end
  end
end
