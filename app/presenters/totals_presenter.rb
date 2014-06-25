module TotalsPresenter
  def discount
    totals[:discount]
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

  def totals
    @totals ||= items.inject(discount: 0, gross: 0, net: 0, payment: 0, transaction: 0, market: 0) do |totals, item|
      next totals if item.delivery_status == "canceled"

      totals[:discount]    += item.discount
      totals[:gross]       += item.gross_total
      totals[:transaction] += item.local_orbit_seller_fee
      totals[:net]         += item.seller_net_total
      totals[:payment]     += item.payment_seller_fee
      totals[:market]      += item.market_seller_fee
      totals
    end
  end
end
