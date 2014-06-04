class AttemptBalancedPurchase
  include Interactor

  def perform
    if ['credit card', 'ach'].include?(payment_method) && order
      begin
        amount = (cart.total * 100).to_i #USD in cents

        debit = create_debit(amount)
        record_payment(debit)
        update_order_payment_method

        if !context[:payment].persisted?
          debit.refund
          context.fail!
        end

      rescue Exception => e
        Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?

        context[:order].errors.add(:credit_card, "Payment processor error.")
        context.fail!

        raise e if Rails.env.development?
      end
    end
  end

  def rollback
    if context[:payment]
      Balanced::Debit.find(payment.balanced_uri).refund
      context.delete(:payment)
    end
  end

  def balanced_source_uri
    if payment_method == 'credit card'
      cart.organization.bank_accounts.find(order_params["credit_card"]).balanced_uri
    else
      cart.organization.bank_accounts.find(order_params["bank_account"]).balanced_uri
    end
  end

  def payment_method
    order_params["payment_method"]
  end

  def initial_payment_status
    if payment_method == 'credit card'
      "paid"
    else
      "pending"
    end
  end

  def create_debit(amount)
    cart.organization.balanced_customer.debit(
      amount: amount,
      source_uri: balanced_source_uri,
      description: "#{cart.market.name} purchase"
    )
  end

  def record_payment(debit)
    context[:payment] = Payment.create(
      payer: cart.organization,
      payment_method: payment_method,
      amount: cart.total,
      status: initial_payment_status,
      balanced_uri: debit.uri,
      orders: [order]
    )
  end

  def update_order_payment_method
    order.update(payment_method: payment_method, payment_status: initial_payment_status)
  end
end
