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

      order.apply_delivery_address(address)
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
    error_data = {order_id: order.id, delivery_id: delivery_id, error_messages: order.errors.full_messages.join(" ")}
    Honeybadger.notify(
        error_class: "Change Order Delivery",
        error_message: "Can't change delivery on an order.",
        parameters: error_data
      )
    ZendeskMailer.delay.error_intervention(user, "Change Order Delivery", error_data)
    context.fail!
  end
end
