class UpdateQuantities
  include Interactor

  def perform
    context[:previous_quantities] = order.items.map {|item| {id: item.id, quantity: item.quantity, quantity_delivered: item.quantity_delivered} }
    context.fail! unless order.update_attributes(order_params.merge(updated_at: Time.current))
    order.cache_delivery_status
    result = ApplyDiscountToAddedOrderItems.perform(order: order)
    order.save
    order.update_total_cost
    context[:delivery_fees] = order.delivery_fees
  end

  def rollback
    order.update(items_attributes: context[:previous_quantities])
  end
end
