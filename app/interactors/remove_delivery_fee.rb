class RemoveDeliveryFee
  include Interactor

  def perform
      order.update!(delivery_fees: 0)
      if merge.nil? || !merge
        UpdatePurchase.perform(order: order)
      end
  end
end
