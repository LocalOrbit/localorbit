class SendInvoiceEmails
  include Interactor

  def perform
    OrderMailer.invoice(order.id).deliver unless order.organization.users.blank?
  end
end
