class PlaceStripeOrder
  include Interactor::Organizer

  organize(
      CreateStripeCustomerForEntity,
      EnsureCartIsNotEmpty,
      CreateOrder,
      CreateConsignmentTransaction,
      CreateTemporaryStripeCreditCard,
      ApplyDiscountToOrderItems,
      StoreOrderFees,
      AttemptPurchaseOrderPurchase,
      AttemptPurchase,
      SendOrderEmails,
      DeleteCart
  )
end
