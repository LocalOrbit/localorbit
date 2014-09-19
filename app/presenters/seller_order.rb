class SellerOrder
  include ActiveModel::Model
  include DeliveryStatus
  include OrderPresenter

  delegate :display_delivery_or_pickup, :display_delivery_address, :delivery_id, :organization_id, to: :@order

  def initialize(order, seller)
    @order = order.decorate
    if seller.is_a?(User)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.managed_organization_ids_including_deleted).order("order_items.name")
    elsif seller.is_a?(Organization)
      @items = order.items.select("order_items.*").joins(:product).where("products.organization_id" => seller.id).order("order_items.name")
    end
  end

  def self.collection(org, orders)
    orders.map {|order| SellerOrder.new(order, org) }
  end

  def self.find(seller, ids)
    order = Order.orders_for_seller(seller).find(ids)
    new(order, seller)
  end

  def items_subtotal
    @items.each.sum {|i| i.seller_net_total }
  end

  def total_cost
    gross_total - discount
  end

  def errors
    @order.errors
  end

  def items_attributes=(_)
  end

  def delivery_fees
    0
  end
end
