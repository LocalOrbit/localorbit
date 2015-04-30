class PaymentProvider

  def self.place_order(payment_provider, buyer_organization:, user:, order_params:, cart:)
    case payment_provider
    when 'balanced'
      PlaceOrder.perform(payment_provider: payment_provider, entity: buyer_organization, buyer: user,
                         order_params: order_params, cart: cart)
    when 'stripe'
      PlaceStripeOrder.perform(payment_provider: payment_provider, entity: buyer_organization, buyer: user,
                               order_params: order_params, cart: cart)
    else
      raise "unknown payment provider: #{payment_provider}"
    end
  end

  def self.charge_for_order(payment_provider, amount:, bank_account:, market:, order:, buyer_organization:)
    case payment_provider
    when 'balanced'
      buyer_organization.balanced_customer.debit(
        amount: amount,
        source_uri: bank_account.balanced_uri,
        description: "#{market.name} purchase",
        appears_on_statement_as: market.on_statement_as,
        meta: {'order number' => order.order_number}
      ) 
    when 'stripe'
      customer = buyer_organization.stripe_customer_id
      source = bank_account.stripe_id
      destination = market.stripe_account_id
      descriptor = market.on_statement_as
      fee = order.items.inject(0) do |total, item|
        item.payment_seller_fee + 
        item.payment_market_fee + 
        item.local_orbit_seller_fee + 
        item.local_orbit_market_fee + 
        total
      end
      fee = ::Financials::MoneyHelpers.amount_to_cents(fee)
      Stripe::Charge.create(amount: amount, currency: 'usd', 
                            source: source, customer: customer,
                            destination: destination, statement_descriptor: descriptor,
                            application_fee: fee)
    else
      raise "unknown payment provider: #{payment_provider}"
    end
  end

  def self.translate_status(payment_provider, cart:, charge:, payment_method:)
    case payment_provider
    when 'balanced'
      if cart.total == 0 || payment_method == "credit card"
        "paid"
      else
        "pending"
      end
    when 'stripe'
      case charge.status
      when 'pending'   then 'pending'
      when 'succeeded' then 'paid'
      when 'failed'    then 'failed'
      end
    end
  end

  def self.create_order_payment(payment_provider, charge:, market_id:, bank_account:, payer:,
                                payment_method:, amount:, order:, status:)
    args = {
      market_id: market_id,
      bank_account: bank_account,
      payer: payer,
      payment_method: payment_method,
      amount: amount,
      payment_type: 'order',
      orders: [order],
      status: status
    }
    case payment_provider
    when 'balanced'
      args[:balanced_uri] = charge.try(:uri)
    when 'stripe'
      args[:stripe_id] = charge.try(:id)
    end
    Payment.create(args)
  end

  def self.fully_refund(payment_provider, charge:nil, payment:, order:)
    case payment_provider
    when 'balanced'
      charge ||= Balanced::Debit.find(payment.balanced_uri)
      charge.refund
    when 'stripe'
      charge ||= Stripe::Charge.retrieve(payment.stripe_id)
      charge.refunds.create(refund_application_fee: true,
                            reverse_transfer: true,
                            metadata: { 'lo.order_id' => order.id,
                                         'lo.order_number' => order.order_number})
    end
  end


end
