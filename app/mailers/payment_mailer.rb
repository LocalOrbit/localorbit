class PaymentMailer < BaseMailer
  def payment_made(recipients, payment)
    @payment = payment
    @market  = @payment.market

    mail(
      to: recipients,
      subject: "You Have Made a Payment"
    )
  end

  def payment_received(recipients, payment)
    @payment = payment
    @market  = @payment.market

    mail(
      to: recipients,
      subject: "You Have Received a Payment"
    )
  end
end
