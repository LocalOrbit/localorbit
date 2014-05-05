class SellerPaymentGroup
  attr_reader :orders
  attr_reader :organization

  def self.for_user(user)
    scope = Order.select('orders.*, products.organization_id as seller_id').joins(:items => :product).
      joins("LEFT JOIN order_payments ON order_payments.order_id = orders.id").
      joins("LEFT JOIN payments ON order_payments.payment_id = payments.id AND products.organization_id = payments.payee_id").
      where("order_items.delivered_at < ? AND (payments.id IS NULL OR payments.payee_type != ?)", 48.hours.ago, "Organization").
      order("orders.order_number")

    scope = scope.where(market_id: user.managed_market_ids) unless user.admin?

    orders_by_seller_id = scope.group_by {|order| [order.seller_id, order.market_id] }

    orders_by_seller_id.map {|(org_id, market_id), orders| new(org_id, orders) }.sort_by {|s| s.market_name }.sort_by {|s| s.name }
  end

  def initialize(org_id, orders)
    @organization = Organization.find(org_id)
    @orders = orders.uniq.map {|order| SellerOrder.new(order, @organization) }
    @orders.reject! {|order| order.items.any? {|item| item.delivery_status != 'delivered' || item.delivered_at > 2.days.ago } }
  end

  def id
    @organization.id
  end

  def market_name
    @orders.first.market.name
  end

  def name
    @organization.name
  end

  def order_count
    @orders.size
  end

  def unpaid_count
    @unpaid_count ||= @orders.reject {|o| o.payment_status == 'paid' }.size
  end

  def owed
    @owed ||= @orders.map(&:items).flatten.sum(&:seller_net_total)
  end
end
