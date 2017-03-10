class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    CreateStripeCustomerForEntity, 
    EnsureCartIsNotEmpty,
    CreateOrder,
    CreateConsignmentProducts,
    CreateTemporaryStripeCreditCard, 
    ApplyDiscountToOrderItems,
    StoreOrderFees,
    AttemptPurchaseOrderPurchase,
    AttemptPurchase,
    SendOrderEmails,
    DeleteCart
  )
end
