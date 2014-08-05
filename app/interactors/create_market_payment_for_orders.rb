class CreateMarketPaymentForOrders
  include Interactor

  def perform
    market       = Market.find(market_id)
    bank_account = market.bank_accounts.find(bank_account_id)
    orders       = market.orders.find(order_ids)

    context[:payment] = Payment.create(
      orders:         orders,
      market:         market,
      bank_account:   bank_account,
      payee:          market,
      payment_type:   "market payment",
      amount:         orders.sum {|o| o.payable_to_market },
      status:         "pending",
      payment_method: "ach"
    )
  end
end
