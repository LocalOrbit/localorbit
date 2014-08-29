class CreateInvoice
  include Interactor

  def perform
    result = MarkOrderInvoiced.perform(order: order)
    result.success? ? GenerateInvoicePdfAndSend.delay.perform(order: order) : fail!
  end
end
