class PaymentMadeEmailConfirmation
  include Interactor

  def perform
    PaymentMailer.delay.payment_made(recipients, payment.id)
  end
end
