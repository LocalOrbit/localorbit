class UpdateOrderItemsStatus
  include Interactor::Organizer

  organize SetOrderItemsStatus, UpdateOrdersForItems
end
