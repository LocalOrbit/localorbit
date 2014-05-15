class SellerOrder
  include DeliveryStatus
  include OrderPresenter

  def initialize(order, seller)
    @order = order
    if seller.is_a?(User)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.managed_organizations.pluck(:id)).order('order_items.name')
    elsif seller.is_a?(Organization)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.id).order('order_items.name')
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

  def display_delivery_or_pickup
    delivery.delivery_schedule.buyer_pickup? ? "can be picked up at:" : "will be delivered to:"
  end

  def display_delivery_address
    "#{delivery_address}, #{delivery_city}, #{delivery_state} #{delivery_zip}"
  end
end
