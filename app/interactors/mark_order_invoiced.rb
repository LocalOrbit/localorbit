class MarkOrderInvoiced
  include Interactor

  def perform
    order.invoice
    order.save || fail!
  end
end
