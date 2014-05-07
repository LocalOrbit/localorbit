class SendInvoice
  include Interactor

  def perform
    order.invoice
    order.save || fail!

    send_email
  end

  def send_email
    addresses = order.organization.users.map(&:email)
    OrderMailer.delay.invoice(order.id, addresses) unless addresses.blank?
  end
end
