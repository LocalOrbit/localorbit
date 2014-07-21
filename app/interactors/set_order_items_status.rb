class SetOrderItemsStatus
  include Interactor

  def perform
    order_items = OrderItem.for_user(user, market_context).where(id: order_item_ids)
    order_items.each do |item|
      item.delivery_status = delivery_status
      item.save
      orders << item.order
    end

    # save orders (with callbacks)
    orders.map(&:save)
  end
end
