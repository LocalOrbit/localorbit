class CreateServicePayment
  include Interactor

  def setup
    invoice      ||= context[:invoice]
    market       ||= context[:market] ||= context[:entity]
  end

  def perform
    bank_account ||= BankAccount.find_by stripe_id: context[:bank_account_params].id  if context[:bank_account_params].class == Stripe::Card
    amount = ::Financials::MoneyHelpers.cents_to_amount(invoice.amount_due)
    context[:payment] = Payment.create({
      payment_provider: market.payment_provider,
      payment_type:     "service",
      market:           market,
      payer:            market,
      amount:           amount,
      stripe_id:        invoice.charge,
      bank_account:     bank_account,
      payment_method:   bank_account.bank_account? ? "ach" : "credit card",
      status:           bank_account.bank_account? ? "pending" : "paid"
    })

    context[:recipients] = market.managers.map(&:pretty_email)

    unless context[:payment].valid?
      context.fail!(error: "Could not create payment record in database")
    end
  end

  def rollback
    if payment = context[:payment]
      payment.destroy
    end

    # FYI context[:recipients] exist only in the context and, therefore, are not subject to rollback
  end
end
