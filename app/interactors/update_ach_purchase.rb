class UpdateAchPurchase
  include Interactor

  def perform
    if order.payment_method == "ach"
      current_amount = rollup_payment_amounts

      if current_amount > order.total_cost
        refund_amount = current_amount - order.total_cost

        refund(refund_amount)
        fail! if context[:status] == 'failed'

        adjustment_payment = Payment.create(payer: order.organization, payment_type: "order refund", payment_method: 'ACH', amount: -refund_amount, status: context[:status])
        order.payments << adjustment_payment
      elsif current_amount < order.total_cost
        charge_amount = order.total_cost - current_amount

        charge(charge_amount)
        fail! if context[:status] == 'failed'

        adjustment_payment = Payment.create(payer: order.organization, payment_type: "order", payment_method: 'ACH', amount: charge_amount, status: context[:status])
        order.payments << adjustment_payment
      end
    end
  end

  def rollup_payment_amounts
    order.payments.refundable.inject(0) {|sum, payment| sum = sum + payment.amount }
  end

  def refund(amount)
    begin
      remaining_amount = amount
      order.payments.refundable.each do |payment|
        break unless remaining_amount

        debit = Balanced::Debit.find(payment.balanced_uri)
        refund_amount = [debit.amount, remaining_amount * 100].min.to_i
        debit.refund(amount: refund_amount)

        remaining_amount -= refund_amount / 100.0
      end
      context[:status] = 'paid'
    rescue
      context[:status] = 'failed'
    end
  end

  def charge(amount)
    begin
      debit = Balanced::Debit.find(order.payments.first.balanced_uri)
      customer = Balanced::Customer.find(debit.account.uri)

      customer.debit(
        amount: amount.to_i * 100,
        source_uri: debit.source.uri,
        description: "#{order.market.name} purchase"
      )
      context[:status] = 'paid'
    rescue
      context[:status] = 'failed'
    end
  end
end
