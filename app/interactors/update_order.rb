class UpdateOrder
  include Interactor::Organizer

  organize UpdateQuantities, StoreOrderFees, UpdateBalancedPurchase, SendUpdateEmails
end
