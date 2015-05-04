class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    CreateStripeCustomerForEntity, 
    EnsureCartIsNotEmpty,
    CreateOrder,
    # CreateTemporaryStripeCreditCard, #TODO
    # ApplyDiscountToOrderItems,
    # StoreOrderFees, #TODO
    # AttemptPurchaseOrderPurchase,
    # AttemptPurchase, # TODO
    # SendOrderEmails,
    # DeleteCart
  )
end
