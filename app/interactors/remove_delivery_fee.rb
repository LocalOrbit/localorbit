class RemoveDeliveryFee
  include Interactor

  def perform
    order.update!(delivery_fees: 0)
    UpdatePurchase.perform(order: order, orig_delivery_fees: orig_delivery_fees, remove_delivery_fees: true)
  end
end
