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

  def totals
    @totals ||= items.inject(discount: 0, discount_seller: 0, discount_market: 0, gross: 0, net: 0, payment: 0, transaction: 0, market: 0, discounted_total: 0) do |totals, item|
      next totals if item.delivery_status == "canceled"

      totals[:discount]    += item.discount
      totals[:discount_seller] += item.discount_seller
      totals[:discount_market] += item.discount_market
      totals[:gross]       += item.gross_total
      totals[:discounted_total] += item.discounted_total
      totals[:transaction] += item.local_orbit_seller_fee
      totals[:net]         += item.seller_net_total
      totals[:payment]     += item.payment_seller_fee
      totals[:market]      += item.market_seller_fee
      totals
    end
  end
end
