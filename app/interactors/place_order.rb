class PlaceOrder
  include Interactor::Organizer

  organize EnsureCartIsNotEmpty, CreateOrder, StoreOrderFees, AttemptPurchaseOrderPurchase, AttemptBalancedPurchase, SendOrderEmails, DeleteCart
end
