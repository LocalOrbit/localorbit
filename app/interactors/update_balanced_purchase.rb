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
    order.payments.successful.inject(0) {|sum, payment| sum += payment.amount }
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
    begin
      begin
        remaining_amount = amount
        context[:status] = 'paid'

        ActiveRecord::Base.transaction do
          order.payments.refundable.order(:created_at).each do |payment|

            break unless remaining_amount > 0

            debit, context[:type] = fetch_balanced_debit(payment.balanced_uri)

            refund_amount = [remaining_amount, payment.unrefunded_amount].min
            refund = debit.refund(amount: refund_amount.to_i * 100)

            payment.increment!(:refunded_amount, refund_amount)
            record_payment("order refund", -refund_amount, refund)

            remaining_amount -= refund_amount
          end
        end

      rescue Exception => e
        process_exception(e, "order refund", -amount)

        raise ActiveRecord::Rollback
      end
    rescue ActiveRecord::Rollback
    end
  end

  def charge(amount)
    begin
      debit, context[:type] = fetch_balanced_debit(first_order_payment.balanced_uri)
      customer = Balanced::Customer.find(debit.account.uri)

      new_debit = customer.debit(
        amount: amount.to_i * 100,
        source_uri: debit.source.uri,
        description: "#{order.market.name} purchase"
      )
      context[:status] = 'paid'

      record_payment("order", amount, new_debit)
    rescue Exception => e
      process_exception(e, "order", amount)
    end
  end

  def first_order_payment
    order.payments.refundable.order(:created_at).first
  end

  def fetch_balanced_debit(uri)
    debit = Balanced::Debit.find(uri)
    type = debit.source._type == 'card' ? "credit card" : "ach"

    [debit, type]
  end

  def process_exception(exception, type, amount)
    Honeybadger.notify_or_ignore(exception) unless Rails.env.test? || Rails.env.development?
    record_payment(type, amount, nil)

    context[:status] = 'failed'
    fail!
  end

  def record_payment(type, amount, balanced_record)
    adjustment_payment = Payment.create(
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
end
