class PlaceStripeOrder
  include Interactor::Organizer

  organize(
    # CreateBalancedCustomerForEntity,
    # EnsureCartIsNotEmpty,
    # CreateOrder,
    # CreateTemporaryCreditCard,
    # ApplyDiscountToOrderItems,
    # StoreOrderFees,
    # AttemptPurchaseOrderPurchase,
    # AttemptBalancedPurchase,
    # SendOrderEmails,
    # DeleteCart
  )
end
