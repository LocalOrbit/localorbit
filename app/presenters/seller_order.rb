class SellerOrder
  include DeliveryStatus
  include OrderPresenter

  def initialize(order, seller)
    @order = order
    if seller.is_a?(User)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.managed_organizations.pluck(:id)).order('products.name')
    elsif seller.is_a?(Organization)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.id).order('products.name')
    end
  end

  def self.find(seller, id)
    order = Order.orders_for_seller(seller).find(id)
    new(order, seller)
  end

  def delivery_fees
    0
  end

  def total_cost
    gross_total - discount
  end
end
