class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, StoreOrderFees, UpdateBalancedPurchase
end
