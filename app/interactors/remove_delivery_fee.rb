class RemoveDeliveryFee
  include Interactor

  def perform
      order.update!(delivery_fees: 0)
      UpdatePurchase.perform(order: order)
  end
end
