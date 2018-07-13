class PaymentReceivedEmailConfirmation
  include Interactor

  def perform
    PaymentMailer.delay.payment_received(recipients, payment) if recipients.present?
  end
end
