class RemoveDeliveryFee
  include Interactor

  def perform
      order.update!(delivery_fees: 0)
  end
end
