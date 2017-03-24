class UncloseOrder
  include Interactor

  def perform
    order.qb_ref_id = nil
    order.payment_status = 'unpaid'
    order.save!
  end
end