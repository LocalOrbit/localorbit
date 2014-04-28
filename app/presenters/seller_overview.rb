class SellerOverview
  def initialize(opts={})
    @seller = opts[:seller]
    @market = opts[:market]
    @time = Time.current

    orders_for_seller_in_market = Order.orders_for_seller(@seller).where(market: @market)

    @electronic_payment_orders = orders_for_seller_in_market.where(payment_method: "credit card").where(payment_method: "ach")
    @po_payment_orders = orders_for_seller_in_market.where(market: @market).where(payment_method: "purchase order")
  end

  def overdue
    return 0.0 if @market.po_payment_term.nil?

    cutoff = @time - (@market.po_payment_term + 2).days
    overdue_orders = @po_payment_orders.delivered.unpaid.having("MAX(order_items.delivered_at) < ?", cutoff).includes(:items)

    overdue_orders.inject(0) do |total, order|
      order.items.for_user(@seller).map(&:gross_total).reduce(:+)
    end
  end
end
