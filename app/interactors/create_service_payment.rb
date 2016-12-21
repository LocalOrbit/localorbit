class CreateServicePayment
  include Interactor

  def perform
    invoice ||= context[:invoice]
    entity  ||= context[:entity]
    organization = entity.class == Market ? entity.organization : entity

    account  = context[:bank_account_params]
    bank_account ||= BankAccount.find_by stripe_id: account.id  if account.class == Stripe::Card || account.class == Stripe::BankAccount
    amount = ::Financials::MoneyHelpers.cents_to_amount(invoice.amount_due)

    context[:payment] = Payment.create({
      payment_provider: market.payment_provider,
      payment_type:     "service",
      organization:     organization,
      payer:            organization,
      amount:           amount,
      stripe_id:        invoice.charge,
      bank_account:     bank_account,
      payment_method:   bank_account.bank_account? ? "ach" : "credit card",
      status:           bank_account.bank_account? ? "pending" : "paid"
    })

    unless context[:payment].valid?
      context.fail!(error: "Could not create payment record in database")
    end
  end

  def rollback
    if payment = context[:payment]
      payment.destroy
    end
  end
end
