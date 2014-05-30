class ChargeServiceFee
  include Interactor

  def perform
    payment = Payment.create({
      payment_type: "service",
      amount: amount,
      status: "pending",
      payer: market,
      payment_method: "ach",
      market: market,
      bank_account: bank_account
    })

    begin
      debit = market.balanced_customer.debit(
        amount:                  (amount * 100).to_i,
        source_uri:              bank_account.balanced_uri,
        description:             "Local Orbit Service fee",
        appears_on_statement_as: "Local Orbit"
      )
      payment.update_attributes(balanced_uri: debit.uri)
    rescue
      payment.update_attributes(status: 'failed')
      context.fail!
    end
  end
end
