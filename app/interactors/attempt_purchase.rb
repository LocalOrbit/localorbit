class AttemptPurchase
  include Interactor

  def perform
    if ["credit card", "ach"].include?(payment_method) && order
      begin
        amount = ::Financials::MoneyHelpers.amount_to_cents(cart.total) # USD in cents
        charge = charge_for_order(amount)
        status = PaymentProvider.translate_status(payment_provider, charge: charge, cart: cart, payment_method: payment_method)
        record_payment(charge, status)
        record_charge_metadata(charge)
        update_order_payment_method(status)

        if !context[:payment].persisted?
          PaymentProvider.fully_refund(payment_provider, charge: charge, order: order)
          context.fail!
        end

      rescue => e
        Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?

        binding.pry
        raise e if Rails.env.development?
        context[:order].errors.add(:credit_card, "Payment processor error.")
        context.fail!
      ensure
        PaymentProvider.store_payment_fees(payment_provider, order: order)
      end
    end
  end

  def rollback
    if context[:payment]
      PaymentProvider.fully_refund(payment_provider, payment: payment, order: order) 
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

  def charge_for_order(amount)
    if amount > 0
      PaymentProvider.charge_for_order(payment_provider, amount: amount, buyer_organization: cart.organization,
                                       bank_account: bank_account, market: cart.market, order: order)
    end
  end

  def record_payment(charge, status)
    context[:payment] = PaymentProvider.create_order_payment(payment_provider,
      charge: charge, 
      market_id: cart.market_id,
      bank_account: bank_account,
      payer: cart.organization,
      payment_method: payment_method,
      amount: cart.total,
      status: status,
      order: order
    )
  end

  def update_order_payment_method(status)
    order.update(payment_method: payment_method, payment_status: status)
    order.items.update_all(payment_status: status)
  end

  def record_charge_metadata(charge)
    charge.metadata['lo.payment_id'] = payment.id
    charge.metadata['lo.order_id'] = order.id
    charge.metadata['lo.order_number'] = order.order_number
    charge.save
  end
end
