class PayMarketForOrders
  include Interactor

  def perform
    market       = Market.find(market_id)
    bank_account = market.bank_accounts.find(bank_account_id)
    orders       = market.orders.find(order_ids)

    payment = Payment.create(
      orders:         orders,
      market:         market,
      bank_account:   bank_account,
      payee:          market,
      payment_type:   "market payment",
      amount:         orders.sum {|o| o.payable_to_market },
      status:         "pending",
      payment_method: "ach"
    )

    begin
      balanced_account = Balanced::BankAccount.find(bank_account.balanced_uri)
      credit = balanced_account.credit(
        amount: (payment.amount * 100).to_i,
        appears_on_statement_as: "Local Orbit"
      )

      payment.update_attribute(:balanced_uri, credit.uri)
    rescue => e
      Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?

      payment.update_attribute(:status, "failed")
      context.fail!
    end
  end
end
