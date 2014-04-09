class SetOrderItemsStatus
  include Interactor

  def perform
    order_items = OrderItem.for_user(user).where(id: order_item_ids)
    order_items.each do |item|
      item.delivery_status = delivery_status
      item.save
    end
  end
end