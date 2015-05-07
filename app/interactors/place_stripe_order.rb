class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    CreateStripeCustomerForEntity, 
    EnsureCartIsNotEmpty,
    CreateOrder,
    CreateTemporaryStripeCreditCard, 
    ApplyDiscountToOrderItems,
    StoreOrderFees,
    AttemptPurchaseOrderPurchase,
    AttemptPurchase,
    SendOrderEmails,
    DeleteCart
  )
end
