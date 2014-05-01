class SellerOverview
  def initialize(opts={})
    @seller = opts[:seller]
    @market = opts[:market]
    @time = Time.current

    base_order_scope = Order.orders_for_seller(@seller).where(market: @market)

    @cc_ach_orders = base_order_scope.paid_with(["credit card", "ach"])
    @po_orders = base_order_scope.paid_with("purchase order")
  end

  def overdue
    sum_seller_items(@po_orders.delivered.payment_overdue)
  end

  def today
    orders = []
    start_of_day = 7.days.ago(@time).beginning_of_day
    end_of_day = @time.end_of_day - 7.days

    orders += @cc_ach_orders.delivered.paid.having("MAX(order_items.delivered_at) >= ?", start_of_day).having("MAX(order_items.delivered_at) < ?", end_of_day)
    orders += @po_orders.delivered.paid.where(paid_at: start_of_day..end_of_day)

    sum_seller_items(orders)
  end

  def next_seven_days
    orders = []
    range_start = (@time + 1.day).beginning_of_day - 7.days
    range_end = (range_start + 6.days).end_of_day

    orders += @cc_ach_orders.delivered.paid.having("MAX(order_items.delivered_at) >= ?", range_start).having("MAX(order_items.delivered_at) < ?", range_end)
    orders += @po_orders.delivered.paid.where(paid_at: range_start..range_end)

    sum_seller_items(orders)
  end

  private

  def sum_seller_items(orders)
    orders.inject(0) do |total, order|
      total += order.items.for_user(@seller).map(&:gross_total).reduce(:+)
    end
  end
end
