class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantityDelivered, StoreOrderFees, UpdateBalancedPurchase
end
