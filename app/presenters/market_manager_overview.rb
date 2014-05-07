class MarketManagerOverview < FinancialOverview
  def initialize(opts={})
    super
    @calculation_method = :gross_total
  end

  def next_thirty_days
    range_start = (@time + 1.day).beginning_of_day - 30.days
    range_end = (range_start + 29.days).end_of_day

    range_start..range_end
  end

  def money_out_next_seven
    orders = []
    orders += @cc_ach_orders.paid.delivered_between(next_seven_days)
    orders += @po_orders.delivered.paid_between(next_seven_days)

    sum_money_to_sellers(orders)
  end

  def money_in_next_thirty
    orders = []
    orders += @cc_ach_orders.delivered.paid.delivered_between(next_seven_days)
    orders += @po_orders.delivered.paid.delivered_between(next_thirty_days)

    sum_seller_items(orders)
  end

  def money_in_purchase_orders
    orders = []
    orders += @po_orders.delivered.uninvoiced
    sum_seller_items(orders)
  end

  def lo_fees_next_seven_days
    orders = @po_orders.delivered.paid_between(next_seven_days)
    sum_local_orbit_fees(orders)
  end

  private
  def sum_money_to_sellers(orders)
    orders.inject(0) do |total, order|
      total + order.items.map(&:seller_net_total).reduce(:+)
    end
  end

  def sum_local_orbit_fees(orders)
    orders.inject(0) do |total, order|
      total + order.items.sum(:local_orbit_market_fee)
    end
  end
end
