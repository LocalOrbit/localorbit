class PaymentMailer < BaseMailer
  def payment_made(recipients, payment_id)
    @payment = Payment.find(payment_id)
    @market  = @payment.market

    mail(
      to: recipients,
      subject: "You Have Made a Payment"
    )
  end

  def payment_received(recipients, payment_id)
    @payment = Payment.find(payment_id)
    @market  = @payment.market

    mail(
      to: recipients,
      subject: "You Received Made a Payment"
    )
  end
end
