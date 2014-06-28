class UpdateOrderWithNewItems
  include Interactor::Organizer

  organize AddItemsToOrder, StoreOrderFees, UpdateBalancedPurchase
end