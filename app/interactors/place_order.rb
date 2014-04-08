class PlaceOrder
  include Interactor::Organizer

  organize CreateOrder, StoreOrderFees, SendOrderEmails, DeleteCart
end
