class PlaceOrder
  include Interactor::Organizer

  organize CreateBalancedCustomerForEntity, EnsureCartIsNotEmpty, CreateOrder, CreateTemporaryCreditCard, StoreOrderFees, AttemptPurchaseOrderPurchase, AttemptBalancedPurchase, SendOrderEmails, DeleteCart
end
