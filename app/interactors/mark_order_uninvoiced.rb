class MarkOrderUninvoiced
  include Interactor

  def perform
    order.uninvoice
    order.save || fail!
  end
end
