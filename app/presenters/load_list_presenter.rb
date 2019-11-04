class LoadListPresenter
  attr_reader :order_items, :delivery, :buyer_pickup_location

  def initialize(order_items)
    @order_items = order_items
    @delivery = order_items.first.order.delivery.decorate
    @buyer_pickup_location = @delivery.delivery_schedule.buyer_pickup_location
  end

  def buyer_pickup?
    @delivery.delivery_schedule.buyer_pickup?
  end

  def buyer_delivery_method
    buyer_pickup? ? 'Pickup' : 'Delivery'
  end

  def buyer_delivery_location_label
    buyer_pickup? ? @delivery.delivery_schedule.buyer_pickup_location.name : 'Direct to customer'
  end
end
