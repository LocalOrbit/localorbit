class AttemptBalancedPurchase
  include Interactor
  include MoneyHelpers

  def perform
    if ["credit card", "ach"].include?(payment_method) && order
      begin
        amount = amount_to_cents(cart.total) # USD in cents
        debit = create_debit(amount)
        record_payment(debit)
        update_order_payment_method

        if !context[:payment].persisted?
          debit.refund
          context.fail!
        end

      rescue => e
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

  def bank_account
    id = payment_method == "credit card" ? order_params["credit_card"]["id"] : order_params["bank_account"]
    @bank_account ||= cart.organization.bank_accounts.find(id)
  end

  def payment_method
    order_params["payment_method"]
  end

  def initial_payment_status
    if cart.total == 0 || payment_method == "credit card"
      "paid"
    else
      "pending"
    end
  end

  def create_debit(amount)
    cart.organization.balanced_customer.debit(
      amount: amount,
      source_uri: bank_account.balanced_uri,
      description: "#{cart.market.name} purchase"
    ) if amount > 0
  end

  def record_payment(debit)
    context[:payment] = Payment.create(
      market_id: cart.market_id,
      bank_account: bank_account,
      payer: cart.organization,
      payment_method: payment_method,
      amount: cart.total,
      status: initial_payment_status,
      balanced_uri: debit.try(:uri),
      orders: [order]
    )
  end

  def update_order_payment_method
    order.update(payment_method: payment_method, payment_status: initial_payment_status)
    order.items.update_all(payment_status: initial_payment_status)
  end
end
