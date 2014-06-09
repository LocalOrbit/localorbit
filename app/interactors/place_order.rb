class PlaceOrder
  include Interactor::Organizer

  organize EnsureCartIsNotEmpty, CreateOrder, CreateTemporaryCreditCard, StoreOrderFees, AttemptPurchaseOrderPurchase, AttemptBalancedPurchase, SendOrderEmails, DeleteCart
end
