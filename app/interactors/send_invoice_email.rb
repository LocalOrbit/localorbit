class SendInvoiceEmail
  include Interactor

  def perform
    OrderMailer.delay.invoice(order.id) unless order.organization.users.blank?
  end
end
