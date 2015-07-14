module TotalsPresenter
  def discount
    totals[:discount]
  end

  def discount_seller
    totals[:discount_seller]
  end

  def discount_market
    totals[:discount_market]
  end

  def gross_total
    totals[:gross]
  end

  def net_total
    totals[:net]
  end

  def payment_fees
    totals[:payment]
  end

  def transaction_fees
    totals[:transaction]
  end

  def market_fees
    totals[:market]
  end

  def discounted_total
    totals[:discounted_total]
  end

  def delivery_fees
    totals[:delivery]
  end

  def totals
    return @totals if @totals
    @totals = {discount: 0, discount_seller: 0, gross: 0, discounted_total: 0, transaction: 0, net: 0, payment: 0, market: 0, delivery: 0}
    @order_ids = []
    non_cancelled_items = items.where("order_items.delivery_status != 'canceled'")
    non_cancelled_items.each do |item|
      @order_ids.push(item.order_id)
      @totals[:discount]    += item.discount
      @totals[:gross]       += item.gross_total
      @totals[:discounted_total] += item.discounted_total
      @totals[:net]         += item.seller_net_total
    end

    @totals[:discount_seller] = non_cancelled_items.sum(:discount_seller)
    @totals[:discount_market] = non_cancelled_items.sum(:discount_market)
    @totals[:transaction] = non_cancelled_items.sum(:local_orbit_seller_fee)
    @totals[:payment] = non_cancelled_items.sum(:payment_seller_fee)
    @totals[:market] = non_cancelled_items.sum(:market_seller_fee)
    @totals[:delivery] = Order.where(id: @order_ids.uniq).sum(:delivery_fees)
    @totals
  end
end
