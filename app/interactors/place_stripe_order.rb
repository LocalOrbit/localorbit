class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    CreateStripeCustomerForEntity, 
    EnsureCartIsNotEmpty,
    CreateOrder,
    UpdateConsignmentTransaction,
    CreateTemporaryStripeCreditCard, 
    ApplyDiscountToOrderItems,
    StoreOrderFees,
    AttemptPurchaseOrderPurchase,
    AttemptPurchase,
    SendOrderEmails,
    DeleteCart
  )
end
