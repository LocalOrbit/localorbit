class BuyerOrder
  include OrderPresenter

  def initialize(order, org)
    @order = order
    @items = order.items
  end

  def self.find(buyer, id)
    order = Order.orders_for_buyer(buyer).find(id)
    new(order, buyer)
  end
end
