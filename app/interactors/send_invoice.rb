class SendInvoice
  include Interactor

  def perform
    order.invoice
    order.save || fail!

    send_email
  end

  def send_email
    addresses = order.organization.users.map(&:email).join(", ")
    OrderMailer.invoice(BuyerOrder.new(order), addresses).deliver unless addresses.blank?
  end
end
