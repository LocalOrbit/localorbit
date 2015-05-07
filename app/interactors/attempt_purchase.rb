# NOTE: Though this is essentially a generified version of AttemptBalancedPurchase, we never
# swithced PlaceOrder over to using this, so essentially we're only using this interactor for PlaceStripeOrder.
# crosby 5/5/2015
#
class AttemptPurchase
  include Interactor

  def perform
    # The following assignments are redundant given Interactor's context magic.
    # I hate Interactor's context magic.    crosby 5/6/2015
    payment_provider = context[:payment_provider]
    cart             = context[:cart] 
    order            = context[:order] 
    order_params     = context[:order_params]
    payment_method   = order_params['payment_method']
    buyer_organization = cart.organization

    return if order.nil?

    begin
      unless PaymentProvider.supports_payment_method?(payment_provider, payment_method)
        raise "AttemptPurchase invoked with payment_method=#{payment_method}, but #{payment_provider} payment provider does NOT support this payment method!"
        # ... this should get caught and reported below in the 'rescue' clause
      end


      #
      # Charge for the order
      #
      charge = nil
      bank_account = nil
      if cart.total > 0
        bank_account_id = if payment_method == "credit card" 
                            order_params["credit_card"]["id"] 
                          else
                            order_params["bank_account"]
                          end
        bank_account = buyer_organization.bank_accounts.find(bank_account_id)

        charge = PaymentProvider.charge_for_order(payment_provider, 
                                                  amount:             cart.total, 
                                                  buyer_organization: buyer_organization,
                                                  bank_account:       bank_account,
                                                  market:             cart.market, 
                                                  order:              order)
      end
      status = PaymentProvider.translate_status(payment_provider, 
                                                charge: charge, 
                                                cart: cart, 
                                                payment_method: payment_method)
      #
      # Record payment
      #
      payment = PaymentProvider.create_order_payment(payment_provider,
                                                     charge:         charge, 
                                                     market_id:      cart.market_id,
                                                     bank_account:   bank_account,
                                                     payer:          buyer_organization,
                                                     payment_method: payment_method,
                                                     amount:         cart.total,
                                                     status:         status,
                                                     order:          order)

      
      #
      # Record metadata on the charge
      #   (NOTE: This is NOT generic, but accidentally tilted toward Stripe's metadata structure. 
      #   Which is ok since we're not actually pushing Balanced processing through this interactor.  
      #   crosby 5/5/2015)
      #
      if charge
        charge.metadata['lo.payment_id'] = payment.id
        charge.metadata['lo.order_id'] = order.id
        charge.metadata['lo.order_number'] = order.order_number
        charge.save
      end

      #
      # Update status and payment method on the order and all items:
      #
      order.update(payment_method: payment_method, 
                   payment_status: status)
      order.items.update_all(payment_status: status)

      context[:payment] = payment

      # Execute a refund if Payment didn't save to our database correctly:
      # TODO: Someday we should decide just how stupid this maneuver really is and see if there's an alternative.  crosby 5/6/2015
      if !payment.persisted?
        PaymentProvider.fully_refund(payment_provider, 
                                     charge: charge, 
                                     order: order)
        context.fail!
      end

    rescue => e
      binding.pry
      Honeybadger.notify_or_ignore(e) unless Rails.env.test? || Rails.env.development?
      raise e if Rails.env.development?
      context[:order].errors.add(:credit_card, "Payment processor error.")
      context.fail!
    ensure
      PaymentProvider.store_payment_fees(context[:payment_provider], order: context[:order])
    end
  end

  def rollback
    if context[:payment]
      PaymentProvider.fully_refund(context[:payment_provider], 
                                   payment: context[:payment], 
                                   order: context[:order]) 
      context.delete(:payment)
    end
  end

end
