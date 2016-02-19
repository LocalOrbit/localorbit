class CreateServicePayment
  include Interactor

  def perform
    context[:payment] = Payment.create({
      payment_provider: market.payment_provider,
      payment_type:     "service",
      market:           market,
      payer:            market,
      amount:           amount,
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

    if recipients = context[:recipients]
      recipients.destroy
    end
  end
end
