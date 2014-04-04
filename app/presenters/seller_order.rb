class SellerOrder
  include DeliveryStatus
  include OrderPresenter

  def initialize(order, org)
    @order = order
    @items = order.items.select("order_items.*").joins(:product).where('products.organization_id' => org.organization_ids)
  end

  def self.find(seller, id)
    order = Order.orders_for_seller(seller).find(id)
    new(order, seller)
  end
end
