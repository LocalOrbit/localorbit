class UpdateQuantities
  include Interactor

  def perform
    context[:previous_quantities] = order.items.map {|item| {id: item.id, quantity: item.quantity, quantity_delivered: item.quantity_delivered} }
    binding.pry
    fail! unless order.update(order_params.merge(updated_at: Time.current))
    order.cache_delivery_status
    order.save
  end

  def rollback
    order.update(items_attributes: context[:previous_quantities])
  end
end
