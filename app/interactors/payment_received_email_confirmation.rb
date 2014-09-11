class PaymentReceivedEmailConfirmation
  include Interactor

  def perform
    PaymentMailer.delay.payment_received(recipients, payment.id) if recipients.present?
  end
end
