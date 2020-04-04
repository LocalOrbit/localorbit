class UpdateQuantities
  include Interactor

  def perform
    context[:previous_quantities] = order.items.map {|item| {id: item.id, quantity: item.quantity, quantity_delivered: item.quantity_delivered, delivery_status: item.delivery_status} }
    context.fail! unless order.update_attributes(order_params.merge(updated_at: Time.current))
    order.cache_delivery_status
    result = ApplyDiscountToAddedOrderItems.perform(order: order)
    order.save
    order.update_total_cost
    context[:delivery_fees] = order.delivery_fees
  end

  def rollback
    prev_qty = context[:previous_quantities].each { |h| h.delete(:delivery_status) }
    order.update(items_attributes: prev_qty)
  end
end
