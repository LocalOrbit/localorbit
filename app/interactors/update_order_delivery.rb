class UpdateOrderDelivery
  include Interactor

  def perform
    if order.market.is_buysell_market?

      if schedule_and_location_changed?
        if new_delivery.requires_location?
          if order.organization.locations.visible.count == 1
            address = order.organization.locations.visible.first
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
    else
      if !order.delivery.deliver_on.nil?
        order.delivery.deliver_on = deliver_on
        order.delivery.buyer_deliver_on = deliver_on
        order.delivery.save
        order.items.each do |item|
          if !item.quantity_delivered.nil? && item.quantity_delivered > 0
            item.delivered_at = deliver_on
            item.save
          end
        end
      end
    end
    if order.valid?
      order.save
      if order.market.is_buysell_market?
        UpdateDeliveryFee.perform(order: order)
        UpdatePurchase.perform(order: order)
      end
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
    #Rollbar.notify(
    #    error_class: "Change Order Delivery",
    #    error_message: "Can't change delivery on an order.",
    #    parameters: error_data
    #  )
    ZendeskMailer.delay.error_intervention(user, "Change Order Delivery", error_data)
    context.fail!
  end
end
