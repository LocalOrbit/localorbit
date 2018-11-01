class CreateInvoice
  include Interactor

  def perform
    result = MarkOrderInvoiced.perform(order: order)
    result.success? ? GenerateInvoicePdfAndSend.delay(priority: 15).perform(request: request, order: order) : fail!
  end
end
