class RecordVendorPayment
  include Interactor
  include ActiveSupport::NumberHelper

  def perform
    payment = Payment.new(payment_params)
    payment.payer        = payment.orders.first.market
    payment.market_id    = payment.payer_id
    payment.payee        = seller
    payment.amount       = payment.orders.map {|order| SellerOrder.new(order, seller).net_total }.sum
    payment.status       = "paid" if payment.payment_method == "cash" || payment.payment_method == "check"
    payment.payment_type = "seller payment"
    if payment.save
      context[:flash_message] = {notice: "Payment of #{number_to_currency payment.amount} recorded for #{seller.name}"}
    else
      context[:flash_message] = {alert: "Could not record payment for #{seller.name}"}
      fail!
    end
  end
end
