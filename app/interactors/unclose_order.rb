class UncloseOrder
  include Interactor

  def perform
    order.qb_ref_id = nil
    order.save!
  end
end