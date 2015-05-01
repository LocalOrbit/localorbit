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


      fee = if bank_account.credit_card?
              PaymentProvider::Stripe::FeeStructure.estimate_credit_card_processing_fee(amount)
            else
              PaymentProvider::Stripe::FeeStructure.estimate_ach_processing_fee(amount)
            end

      charge = Stripe::Charge.create(amount: amount, currency: 'usd', 
                            source: source, customer: customer,
                            destination: destination, statement_descriptor: descriptor,
                            application_fee: fee)

    else
      raise "unknown payment provider: #{payment_provider}"
    end
  end

  def self.translate_status(payment_provider, cart:nil, charge:, payment_method:nil)
    case payment_provider
    when 'balanced'
      # cart checkout
      if cart
        if cart.total == 0 || payment_method == "credit card"
          "paid"
        else
          "pending"
        end
      else
        # update order
        case charge.try(:status)
        when "pending"
          "pending"
        when "succeeded"
          "paid"
        else
          "failed"
        end
      end
    when 'stripe'
      case charge.try(:status)
      when 'pending'   then 'pending'
      when 'succeeded' then 'paid'
      else
        'failed'
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
      args[:stripe_payment_fee] = get_stripe_application_fee_on_charge(charge)

    end
    Payment.create(args)
  end

  def self.get_stripe_application_fee_on_charge(charge)
    return "0".to_d unless charge

    app_fee = Stripe::ApplicationFee.retrieve(charge.application_fee)
    if app_fee
      ::Financials::MoneyHelpers.cents_to_amount(app_fee.amount - app_fee.amount_refunded)
    else
      "0".to_d
    end
  end

  def self.create_refund_payment(payment_provider, charge:, market_id:, bank_account:, payer:,
                                payment_method:, amount:, order:, status:, refund:, parent_payment:)
    args = {
      market_id: market_id,
      bank_account: bank_account,
      payer: payer,
      payment_method: payment_method,
      amount: amount,
      payment_type: 'order refund',
      orders: [order],
      parent_id: parent_payment.id,
      status: status
    }
    case payment_provider
    when 'balanced'
      args[:balanced_uri] = refund.try(:uri)
    when 'stripe'
      args[:stripe_id] = charge.try(:id)
      args[:stripe_refund_id] = refund.try(:id)
      parent_payment.update stripe_payment_fee: get_stripe_application_fee_on_charge(charge)
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
                                        'lo.order_number' => order.order_number })
    end
  end

  def self.refund_charge(payment_provider, charge:, amount:, order:)
    case payment_provider
    when 'balanced'
      charge.refund(amount: amount)
    when 'stripe'
      charge.refunds.create(refund_application_fee: true,
                            reverse_transfer: true,
                            amount: amount,
                            metadata: { 'lo.order_id' => order.id,
                                        'lo.order_number' => order.order_number })
    end
  end

  def self.find_charge(payment_provider, payment:)
    case payment_provider
    when 'balanced'
      payment.balanced_transaction
    when 'stripe'
      Stripe::Charge.retrieve(payment.stripe_id)
    end
  end

  def self.store_payment_fees(payment_provider, order:)
    case payment_provider
    when 'balanced'
      
    when 'stripe'
      # distribute_fee ...
    end
  end

  private

  def distribute_fee(total_fee_cents, order)
    order_total_cents = ::Financials::MoneyHelpers.amount_to_cents(order.gross_total)
    return [] if order_total_cents == 0
    remaining_fee_cents = total_fee_cents
    quota = order_total_cents.to_r / total_fee_cents.to_r

    items = order.usable_items.reject do |item|
      item.gross_total == 0
    end.map do |item|
      item_total_cents = ::Financials::MoneyHelpers.amount_to_cents(item.gross_total)
      item_fee_cents, remainder = item_total_cents.divmod(quota)
      remaining_fee_cents -= item_fee_cents
      { item: item, fee: item_fee_cents, remainder: remainder }
    end
    sorted_items = items.sort_by {|item| item[:remainder]}.reverse
    remaining_fee_cents.times do 
      item = sorted_items.shift
      item[:fee] += 1
    end
    items
  end

end
