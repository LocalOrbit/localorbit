class PlaceOrder
  include Interactor::Organizer

  organize CreateOrder, StoreOrderFees, DeleteCart
end
