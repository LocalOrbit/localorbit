class CreateServicePayment
  include Interactor

  def perform
    context[:payment] = Payment.create({
      payment_type:   "service",
      market:         market,
      payer:          market,
      amount:         amount,
      bank_account:   bank_account,
      payment_method: bank_account.bank_account? ? "ach" : "credit card",
      status:         bank_account.bank_account? ? "pending" : "paid"
    })

    context[:recipients] = market.managers.map(&:pretty_email)
  end
end
