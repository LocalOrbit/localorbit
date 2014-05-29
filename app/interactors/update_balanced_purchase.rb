class UpdateBalancedPurchase
  include Interactor

  def perform
    if ['credit card', 'ach'].include?(order.payment_method)
      current_amount = rollup_payment_amounts

      if current_amount > order.total_cost
        create_refunds(current_amount)
      elsif current_amount < order.total_cost
        create_new_charge(current_amount)
      end
    end
  end

  def rollup_payment_amounts
    order.payments.refundable.inject(0) {|sum, payment| sum = sum + payment.amount }
  end

  def create_refunds(amount)
    refund_amount = amount - order.total_cost

    refund(refund_amount)
    fail! if context[:status] == 'failed'

    adjustment_payment = Payment.create(
      payer: order.organization,
      payment_type: "order refund",
      payment_method: context[:type],
      amount: -refund_amount,
      status: context[:status]
    )

    order.payments << adjustment_payment
  end

  def refund(amount)
    begin
      remaining_amount = amount
      order.payments.refundable.each do |payment|
        break unless remaining_amount

        debit, context[:type] = fetch_balanced_debit(payment.balanced_uri)

        refund_amount = [debit.amount, remaining_amount * 100].min.to_i
        debit.refund(amount: refund_amount)

        remaining_amount -= refund_amount / 100.0
      end
      context[:status] = 'paid'
    rescue
      context[:status] = 'failed'
    end
  end

  def create_new_charge(amount)
    charge_amount = order.total_cost - amount

    charge(charge_amount)
    fail! if context[:status] == 'failed'

    adjustment_payment = Payment.create(
      payer: order.organization,
      payment_type: "order",
      payment_method: context[:type],
      amount: charge_amount,
      status: context[:status]
    )

    order.payments << adjustment_payment
  end

  def charge(amount)
    begin
      debit, context[:type] = fetch_balanced_debit(first_order_payment.balanced_uri)
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

  def first_order_payment
    order.payments.first
  end

  def fetch_balanced_debit(uri)
    debit = Balanced::Debit.find(uri)
    type = debit.source._type == 'card' ? "credit card" : "ach"

    [debit, type]
  end
end
