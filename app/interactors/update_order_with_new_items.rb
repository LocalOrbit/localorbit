class UpdateOrderWithNewItems
  include Interactor::Organizer
  
  organize AddItemsToOrder, CreateConsignmentTransaction, ApplyDiscountToAddedOrderItems, StoreOrderFees, UpdatePurchase, SendUpdateEmails
end
