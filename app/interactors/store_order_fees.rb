class StoreOrderFees
  include Interactor

  def perform
    calculate_fees

    if order.payment_method == "ach"
      cap_market_fees
      cap_seller_fees
    end

    order.items.each(&:save!)
  end

  protected

  def ach_fee_cap
    @ach_fee_cap ||= market.ach_fee_cap
  end

  def calculate_fees
    order.items.each {|item| update_accounting_fees_for(item) }
  end

  def cap_market_fees
    total = order.items.inject(0) {|sum, item| sum + item.payment_market_fee }
    if total > ach_fee_cap
      order.items.each do |item|
        item.payment_market_fee = ach_fee_cap * item.payment_market_fee / total
      end
    end
  end

  def cap_seller_fees
    order.items.group_by {|item| item.product.organization_id }.each_value do |items|
      total = items.inject(0) {|sum, item| sum + item.payment_seller_fee }
      if total > ach_fee_cap
        items.each do |item|
          item.payment_seller_fee = ach_fee_cap * item.payment_seller_fee / total
        end
      end
    end
  end

  def update_accounting_fees_for(item)
    item.market_seller_fee = Financials::OrderItemFeeCalculator.market_fee_paid_by_seller(market: market, order_item: item)
    item.local_orbit_seller_fee = Financials::OrderItemFeeCalculator.local_orbit_fee_paid_by_seller(market: market, order_item: item)
    item.local_orbit_market_fee = Financials::OrderItemFeeCalculator.local_orbit_fee_paid_by_market(market: market, order_item: item)

    if PaymentProvider.is_balanced?(payment_provider)
      # These calculations were not migrated into Financials:OrderItemFeeCalculator because they are 
      # going to be defunct once Balanced is 100% in our past.   6/2 crosby
      item.payment_seller_fee     = item.discounted_total * (payment_seller_fee / 100)
      item.payment_market_fee     = item.discounted_total * (payment_market_fee / 100)
    end
  end

  def market
    @market ||= order.market
  end

  def payment_seller_fee
    @payment_seller_fee ||=
      case order.payment_method
      when "credit card" then market.credit_card_seller_fee
      when "ach"         then market.ach_seller_fee
      else
        0
      end
  end

  def payment_market_fee
    @payment_market_fee ||=
      case order.payment_method
      when "credit card" then market.credit_card_market_fee
      when "ach"         then market.ach_market_fee
      else
        0
      end
  end
end
