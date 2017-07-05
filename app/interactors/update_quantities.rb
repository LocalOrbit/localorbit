class UpdateQuantities
  include Interactor

  def perform
    context[:previous_quantities] = order.items.map {|item| {id: item.id, quantity: item.quantity, quantity_delivered: item.quantity_delivered, delivery_status: item.delivery_status} }
    context.fail! unless order.update_attributes(order_params.merge(updated_at: Time.current))
    order.cache_delivery_status
    result = ApplyDiscountToAddedOrderItems.perform(order: order)
    if order.market.is_consignment_market? && !order.delivery.deliver_on.nil? && order_params.has_key?(:quantity_delivered)
      d_time = Time.current
      order.delivery.deliver_on = d_time
      order.delivery.buyer_deliver_on = d_time
      order.delivery.save
    end
    order.save
    order.update_total_cost
    context[:delivery_fees] = order.delivery_fees
  end

  def rollback
    order.update(items_attributes: context[:previous_quantities])
  end
end
