class UpdateOrderWithNewItems
  include Interactor::Organizer

  organize AddItemsToOrder, StoreOrderFees, UpdatePurchase
end
