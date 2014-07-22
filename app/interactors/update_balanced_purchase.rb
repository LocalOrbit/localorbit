class UpdateBalancedPurchase
  include Interactor

  def perform
    if ["credit card", "ach"].include?(order.payment_method)
      current_amount = rollup_payment_amounts

      if current_amount > order.total_cost
        create_refunds(current_amount)
      elsif current_amount < order.total_cost
        create_new_charge(current_amount)
      end
    end
  end

  def rollup_payment_amounts
    order.payments.successful.buyer_payments.inject(0) {|sum, payment| sum + payment.amount }
  end

  def create_new_charge(amount)
    charge_amount = order.total_cost - amount
    debit = charge(charge_amount)
  end

  def create_refunds(amount)
    refund_amount = amount - order.total_cost
    refund(refund_amount)
  end

  def refund(amount)
    remaining_amount = amount
    context[:status] = "paid"

    order.payments.refundable.order(:created_at).each do |payment|

      break unless remaining_amount > 0

      begin
        context[:type] = payment.payment_method

        refund_amount = [remaining_amount, payment.unrefunded_amount].min
        refund = payment.balanced_transaction.refund(amount: amount_to_cents(refund_amount))

        payment.increment!(:refunded_amount, refund_amount)
        record_payment("order refund", -refund_amount, refund, payment.bank_account)

        remaining_amount -= refund_amount
      rescue => e
        process_exception(e, "order refund", -refund_amount, payment.bank_account)
        break
      end
    end
  end

  def charge(amount)
    payment = order.payments.buyer_payments.successful.first
    payment ||= order.payments.buyer_payments.first

    account = payment.try(:bank_account) || raise("No chargable accounts found")

    context[:type] = payment.payment_method

    new_debit = account.bankable.balanced_customer.debit(
      amount: amount_to_cents(amount),
      source_uri: account.balanced_uri,
      description: "#{order.market.name} purchase"
    )
    context[:status] = "paid"

    record_payment("order", amount, new_debit, account)
  rescue => e
    process_exception(e, "order", amount, account)
  end

  def process_exception(exception, type, amount, account)
    Honeybadger.notify_or_ignore(exception) unless Rails.env.test? || Rails.env.development?
    record_payment(type, amount, nil, account)

    context[:status] = "failed"
    fail!
  end

  def record_payment(type, amount, balanced_record, bank_account)
    adjustment_payment = Payment.create!(
      market_id: order.market_id,
      bank_account: bank_account,
      payer: order.organization,
      payment_type: type,
      payment_method: context[:type],
      amount: amount,
      status: parse_payment_status(balanced_record.try(:status)),
      balanced_uri: balanced_record.try(:uri)
    )

    order.payments << adjustment_payment
  end

  def parse_payment_status(status)
    case status
    when "pending"
      "pending"
    when "succeeded"
      "paid"
    else
      "failed"
    end
  end

  def amount_to_cents(amount)
    (amount * 100).to_i
  end
end
