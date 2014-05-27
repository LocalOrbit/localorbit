class BuyerOrder
  include ActiveModel::Model
  include OrderPresenter
  include DeliveryStatus

  delegate :display_delivery_or_pickup, :display_delivery_address, to: :@order

  def initialize(order)
    @order = order.decorate
    @items = order.items
  end

  def self.find(buyer, id)
    order = Order.orders_for_buyer(buyer).find(id)
    new(order)
  end

  def total_cost
    @order.total_cost
  end

  def invoice_due_date
    @order.invoice_due_date
  end
end
