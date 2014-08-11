class RefundServicePayment
  include Interactor

  def perform
    context[:refund_payment] = Payment.create({
      payment_type:   "service refund",
      market:         payment.market,
      payer:          payment.market,
      amount:         amount || -payment.amount,
      bank_account:   payment.bank_account,
      payment_method: payment.payment_method,
      status:         payment.bank_account? ? "pending" : "paid",
      parent:         payment
    })
  end
end
