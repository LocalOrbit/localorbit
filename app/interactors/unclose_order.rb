class UncloseOrder
  include Interactor

  def perform
    order.payment_status = 'unpaid'
    order.save!
  end
end