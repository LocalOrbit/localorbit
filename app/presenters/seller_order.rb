class SellerOrder
  include ActiveModel::Model
  include DeliveryStatus
  include OrderPresenter

  delegate :display_delivery_or_pickup, :display_delivery_address, to: :@order

  def initialize(order, seller)
    @order = order.decorate
    if seller.is_a?(User)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.managed_organizations_including_deleted.pluck(:id)).order('order_items.name')
    elsif seller.is_a?(Organization)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.id).order('order_items.name')
    end
  end

  def self.find(seller, id)
    order = Order.orders_for_seller(seller).find(id)
    new(order, seller)
  end

  def total_cost
    gross_total - discount
  end

  def errors
    @order.errors
  end

  def items_attributes=(values)
  end
end
