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
    # NOTE: Refunds are logged as being paid from the order organization,
    # but with a negative amount.

    remaining_amount = amount
    context[:status] = "paid"

    order.payments.refundable.order(:created_at).each do |payment|

      break unless remaining_amount > 0

      begin
        context[:type] = payment.payment_method

        refund_amount = [remaining_amount, payment.unrefunded_amount].min
        charge = PaymentProvider.find_charge(payment_provider, payment: payment)
        refund = PaymentProvider.refund_charge(payment_provider, order: order,
          charge: charge, amount: ::Financials::MoneyHelpers.amount_to_cents(refund_amount))

        payment.increment!(:refunded_amount, refund_amount)
        record_refund(-refund_amount, charge, refund, payment.bank_account, payment)

        remaining_amount -= refund_amount
      rescue => e
        process_exception(e, "order refund", -refund_amount, payment.bank_account, payment)
        break
      end
    end
  end

  def charge(amount)
    payment = order.payments.buyer_payments.successful.first
    payment ||= order.payments.buyer_payments.first

    account = payment.try(:bank_account) || raise("No chargable accounts found")

    context[:type] = payment.payment_method

    charge = PaymentProvider.charge_for_order(order.payment_provider, 
      amount: ::Financials::MoneyHelpers.amount_to_cents(amount),
      bank_account: account, market: order.market, order: order,
      buyer_organization: order.organization)

    context[:status] = "paid"

    record_charge(amount, charge, account)
  rescue => e
    process_exception(e, "order", amount, account)
  end

  def process_exception(exception, type, amount, account, parent_payment=nil)
    Honeybadger.notify_or_ignore(exception) unless Rails.env.test? || Rails.env.development?
    if type == "order"
      record_charge(amount, nil, account)
    else
      record_refund(amount, nil, nil, account, parent_payment)
    end

    context[:status] = "failed"
    fail!
  end

  def record_charge(amount, charge, bank_account)
    status = PaymentProvider.translate_status(payment_provider, charge: charge)
    adjustment_payment = PaymentProvider.create_order_payment(payment_provider,
      charge: charge,
      order: order,
      market_id: order.market_id,
      bank_account: bank_account,
      payer: order.organization,
      payment_method: context[:type],
      amount: amount,
      status: status
    )
  end

  def record_refund(amount, charge, refund, bank_account, parent_payment)
    status = PaymentProvider.translate_status(payment_provider, charge: charge)
    adjustment_payment = PaymentProvider.create_refund_payment(payment_provider,
      charge: charge,
      order: order,
      market_id: order.market_id,
      bank_account: bank_account,
      payer: order.organization,
      payment_method: context[:type],
      amount: amount,
      refund: refund,
      status: status,
      parent_payment: parent_payment
    )
  end

  def payment_provider
    order.payment_provider
  end
end
