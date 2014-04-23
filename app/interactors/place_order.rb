class PlaceOrder
  include Interactor::Organizer

  organize EnsureCartIsNotEmpty, AttemptPurchaseOrderPurchase, AttemptCreditCardPurchase, CreateOrder, StoreOrderFees, SendOrderEmails, DeleteCart
end
