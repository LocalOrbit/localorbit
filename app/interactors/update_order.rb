class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantityDelivered, StoreOrderFees, UpdateCreditCardPurchase, UpdateAchPurchase
end
