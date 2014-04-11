class BuyerOrder
  include OrderPresenter

  def initialize(order)
    @order = order
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
