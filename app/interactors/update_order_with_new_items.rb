class UpdateOrderWithNewItems
  include Interactor::Organizer

  organize AddItemsToOrder, ApplyDiscountToAddedOrderItems, StoreOrderFees, UpdatePurchase

end
