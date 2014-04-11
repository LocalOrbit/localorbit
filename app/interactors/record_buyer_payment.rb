class RecordBuyerPayment
  include Interactor

  def perform
    context[:payment] = order.payments.build(payment_params)
    payment.payee  = order.market
    payment.amount = order.total_cost
    payment.save || context.fail!

    order.update_attribute(:payment_status, 'paid')
  end
end
