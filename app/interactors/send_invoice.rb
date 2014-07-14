class SendInvoice
  include Interactor

  def perform
    order.invoice
    order.save || fail!

    send_email
  end

  def send_email
    OrderMailer.delay.invoice(order.id) unless order.organization.users.blank?
  end
end
