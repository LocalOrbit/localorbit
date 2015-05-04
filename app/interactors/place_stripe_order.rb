class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    # CreateStripeCustomerForEntity, # TODO
    # EnsureCartIsNotEmpty,
    # CreateOrder,
    # CreateTemporaryStripeCreditCard, #TODO
    # ApplyDiscountToOrderItems,
    # StoreOrderFees, #TODO
    # AttemptPurchaseOrderPurchase,
    # AttemptPurchase, # TODO
    # SendOrderEmails,
    # DeleteCart
  )
end
