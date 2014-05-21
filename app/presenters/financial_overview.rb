class FinancialOverview
  def self.build(user, market)
    klass = if user.can_manage_market?(market)
      MarketManagerOverview
    else
      SellerOverview
    end

    klass.new(seller: user, market: market)
  end

  def initialize(opts={})
    @seller = opts[:seller]
    @market = opts[:market]
    @time = Time.current

    base_order_scope = Order.orders_for_seller(@seller).where(market: @market)
    @cc_ach_orders = base_order_scope.paid_with(["credit card", "ach"])
    @po_orders = base_order_scope.paid_with("purchase order")
  end

  def next_seven_days(offset: 0)
    range_start = (@time + 1.day).beginning_of_day + offset.days
    range_end = (range_start + 6.days).end_of_day

    range_start..range_end
  end

  def next_thirty_days(offset: 0)
    range_start = (@time + 1.day).beginning_of_day + offset.days
    range_end = (range_start + 29.days).end_of_day

    range_start..range_end
  end

  def today(offset: 0)
    start_of_day = (@time).beginning_of_day + offset.days
    end_of_day = start_of_day.end_of_day

    start_of_day..end_of_day
  end

  def overdue
    sum_seller_items(@po_orders.delivered.where("invoice_due_date < ?", @time.beginning_of_day))
  end

  private
  def sum_seller_items(orders)
    orders.inject(0) do |total, order|
      total + order.items.for_user(@seller).map(&@calculation_method).reduce(:+)
    end
  end
end
