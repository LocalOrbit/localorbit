class RecordBuyerPayment
  include Interactor

  def perform
    context[:payment] = Payment.new(payment_params)
    payment.market_id = order.market_id
    payment.payee     = order.market
    payment.amount    = order.total_cost
    payment.save || context.fail!

    order.update_attribute(:payment_status, "paid")
    order.payments << payment
  end
end
