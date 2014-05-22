class PlaceOrder
  include Interactor::Organizer

  organize EnsureCartIsNotEmpty, CreateOrder, StoreOrderFees, AttemptPurchaseOrderPurchase, AttemptCreditCardPurchase, AttemptAchPurchase, SendOrderEmails, DeleteCart
end
