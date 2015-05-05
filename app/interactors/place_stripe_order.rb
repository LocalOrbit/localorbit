class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    CreateStripeCustomerForEntity, 
    EnsureCartIsNotEmpty,
    CreateOrder,
    CreateTemporaryStripeCreditCard, 
    ApplyDiscountToOrderItems,
    # StoreOrderFees, #TODO
    # AttemptPurchaseOrderPurchase,
    # AttemptPurchase, # TODO
    # SendOrderEmails,
    # DeleteCart
  )
end
