class UpdateOrderDelivery
  include Interactor

  def perform
    order.delivery_id = delivery_id
    if order.valid?
      order.save
    else
      Honeybadger.notify(
          :error_class   => "Change Order Delivery",
          :error_message => "Can't change delivery on an order: #{order.errors.full_messages}",
          :parameters    => {order_id: order.id, delivery_id: delivery_id}
        )
      fail!
    end
  end
end
