class FinancialOverview
  def initialize(opts={})
    @seller = opts[:seller]
    @market = opts[:market]
    @time = Time.current

    base_order_scope = Order.orders_for_seller(@seller).where(market: @market)

    @cc_ach_orders = base_order_scope.paid_with(["credit card", "ach"])
    @po_orders = base_order_scope.paid_with("purchase order")
  end

  def next_seven_days(offset=0)
    range_start = offset.days.ago(@time + 1.day).beginning_of_day
    range_end = (range_start + 6.days).end_of_day

    range_start..range_end
  end

  def today(offset=0)
    start_of_day = offset.days.ago(@time).beginning_of_day
    end_of_day = offset.days.ago(@time).end_of_day

    start_of_day..end_of_day
  end

  def overdue
    sum_seller_items(@po_orders.delivered.where("invoice_due_date < ?", @time.beginning_of_day))
  end

  def money_in_today
    orders = []

    orders += @cc_ach_orders.paid.delivered_between(today)
    orders += @po_orders.delivered.paid_between(today)

    sum_seller_items(orders)
  end

  def money_in_next_seven
    orders = []

    orders += @cc_ach_orders.paid.delivered_between(next_seven_days)
    orders += @po_orders.delivered.paid_between(next_seven_days)

    sum_seller_items(orders)
  end

  private
  def sum_seller_items(orders)
    orders.inject(0) do |total, order|
      total + order.items.for_user(@seller).map(&@calculation_method).reduce(:+)
    end
  end
end
