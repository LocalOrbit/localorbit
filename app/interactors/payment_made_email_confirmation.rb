class PaymentMadeEmailConfirmation
  include Interactor

  def perform
    PaymentMailer.delay.payment_made(recipients, payment) if recipients.present?
  end
end
