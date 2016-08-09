class UpdateOrderWithNewItems
  include Interactor::Organizer

  organize AddItemsToOrder, ApplyDiscountToOrderItems, StoreOrderFees, UpdatePurchase
end
