class PlaceOrder
  include Interactor::Organizer

  organize AttemptPurchaseOrderPurchase, AttemptCreditCardPurchase, CreateOrder, StoreOrderFees, SendOrderEmails, DeleteCart
end
