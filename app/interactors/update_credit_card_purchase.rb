class UpdateCreditCardPurchase
  include Interactor

  def perform
    if order.payment_method == "credit card"
      current_amount = rollup_payment_amounts

      if current_amount > order.total_cost
        refund_amount = current_amount - order.total_cost

        refund(refund_amount)

        adjustment_payment = Payment.create(payer: order.organization, payment_type: "order refund", payment_method: 'credit card', amount: -refund_amount, status: "paid")
        order.payments << adjustment_payment
      elsif current_amount < order.total_cost
        charge_amount = order.total_cost - current_amount

        charge(charge_amount)

        adjustment_payment = Payment.create(payer: order.organization, payment_type: "order", payment_method: 'credit card', amount: charge_amount, status: "paid")
        order.payments << adjustment_payment
      end
    end
  end

  def rollup_payment_amounts
    order.payments.inject(0) {|sum, payment| sum = sum + payment.amount }
  end

  def refund(amount)
    remaining_amount = amount
    order.payments.each do |payment|
      break unless remaining_amount

      debit = Balanced::Debit.find(payment.balanced_uri)
      refund_amount = [debit.amount, remaining_amount * 100].min.to_i
      debit.refund(amount: refund_amount)

      remaining_amount -= refund_amount / 100.0
    end
  end

  def charge(amount)
    debit = Balanced::Debit.find(order.payments.first.balanced_uri)
    customer = Balanced::Customer.find(debit.account.uri)

    customer.debit(
      amount: amount.to_i * 100,
      source_uri: debit.source.uri,
      description: "#{order.market.name} purchase"
    )
  end
end
