class StoreOrderFees
  include Interactor

  def perform
    @market = order.market
    order.items.each {|item| update_accounting_fees_for(item) }
    order.items.each(&:save!)
  end

#  protected

  def update_accounting_fees_for(item)
    calc = Financials::OrderItemFeeCalculator
    item.market_seller_fee =      calc.market_fee_paid_by_seller(      market: @market, order_item: item)
    item.local_orbit_seller_fee = calc.local_orbit_fee_paid_by_seller( market: @market, order_item: item)
    item.local_orbit_market_fee = calc.local_orbit_fee_paid_by_market( market: @market, order_item: item)
  end

end
