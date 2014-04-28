class PlaceOrder
  include Interactor::Organizer

  organize EnsureCartIsNotEmpty, AttemptPurchaseOrderPurchase, AttemptCreditCardPurchase, AttemptAchPurchase, CreateOrder, StoreOrderFees, SendOrderEmails, DeleteCart
end
