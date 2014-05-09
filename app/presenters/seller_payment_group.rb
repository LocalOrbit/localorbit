class SellerPaymentGroup
  attr_reader :orders
  attr_reader :organization

  def self.for_user(user)
    subselect = "SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = ? AND payments.payee_id = products.organization_id"
    scope = Order.select('orders.*, products.organization_id as seller_id').joins(:items => :product).
      where("NOT EXISTS(#{subselect})", "Organization").
      where("order_items.delivered_at < ?", 48.hours.ago).
      group("orders.id, seller_id").
      order("orders.order_number").
      includes(:market)

    scope = scope.where(market_id: user.managed_market_ids) unless user.admin?

    grouped_orders = scope.group_by {|order| [order.seller_id, order.market_id] }

    # Preload seller organizations
    organizations = Organization.find(grouped_orders.each_key.map(&:first).uniq).index_by(&:id)

    seller_payment_groups = grouped_orders.map {|(org_id, _), orders| new(organizations[org_id], orders) }

    # This sorts the list by seller organization name with a secondary sort on market name
    seller_payment_groups.sort_by {|s| s.market_name }.sort_by {|s| s.name }
  end

  def initialize(org, orders)
    @organization = org
    @orders = orders.map {|order| SellerOrder.new(order, @organization) }
    @orders.reject! {|order| order.items.any? {|item| item.delivery_status != 'delivered' || item.delivered_at > 2.days.ago } }
  end

  def id
    @organization.id
  end

  def market_name
    @market_name ||= @orders.first.market.name
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
    # .each.sum forces the use of ruby sum instead of a sql sum
    @owed ||= @orders.sum {|o| o.items.each.sum {|i| i.seller_net_total } }
  end
end
