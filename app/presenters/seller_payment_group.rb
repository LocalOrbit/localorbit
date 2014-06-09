class SellerPaymentGroup
  attr_reader :orders
  attr_reader :organization

  # This goes on the model
  def self.for_scope(scope)
    grouped_orders = scope.group_by {|order| [order.seller_id, order.market_id] }

    # Preload seller organizations
    organizations = Organization.find(grouped_orders.each_key.map(&:first).uniq).index_by(&:id)

    seller_payment_groups = grouped_orders.map {|(org_id, _), orders| new(organizations[org_id], orders) }
    seller_payment_groups.reject! {|group| group.orders.empty? }

    # This sorts the list by seller organization name with a secondary sort on market name
    seller_payment_groups.sort_by {|s| "#{s.name} / #{s.market_name}" }
  end

  def initialize(org, orders)
    @organization = org
    @orders = orders.map {|order| SellerOrder.new(order, @organization) }
    @orders.select! {|order| order.delivery_status == 'delivered' }
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
