class UpdateOrdersForItems
  include Interactor

  def perform
    orders = Order.joins(:items).where("order_items.id in (?)", order_item_ids).uniq
    orders.each do |order|
      order.save
      StoreOrderFees.perform(payment_provider: order.payment_provider, order: order)
      UpdatePurchase.perform(payment_provider: order.payment_provider, order: order)
    end
  end
end
