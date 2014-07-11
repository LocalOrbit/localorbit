class UpdateOrderDelivery
  include Interactor

  def perform
    if schedule_and_location_changed?
      if new_delivery.requires_location?
        if order.organization.locations.count == 1
          address = order.organization.locations.first
        else
          fail_and_notify
          return
        end
      else
        address = new_delivery.delivery_schedule.buyer_pickup_location
      end

      order.delivery_address = address.address
      order.delivery_city    = address.city
      order.delivery_state   = address.state
      order.delivery_zip     = address.zip
      order.delivery_phone   = address.phone
    end

    order.delivery_id = delivery_id
    if order.valid?
      order.save
      UpdateBalancedPurchase.perform(order: order)
    else
      fail_and_notify
    end
  end

  def new_delivery
    @new_delivery ||= Delivery.find(delivery_id)
  end

  def schedule_and_location_changed?
    delivery_schedule_changed? && delivery_location_changed?
  end

  def delivery_schedule_changed?
    new_delivery.delivery_schedule_id != order.delivery.delivery_schedule_id
  end

  def delivery_location_changed?
    new_delivery.delivery_schedule.buyer_pickup_location_id != order.delivery.delivery_schedule.buyer_pickup_location_id
  end

  def fail_and_notify
    Honeybadger.notify(
        :error_class   => "Change Order Delivery",
        :error_message => "Can't change delivery on an order: #{order.errors.full_messages}",
        :parameters    => {order_id: order.id, delivery_id: delivery_id}
      )
    context.fail!
  end
end
