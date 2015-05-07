module PaymentProvider
  class Stripe
    CreditCardFeeStructure = SchemaValidation.validate!(FeeEstimator::Schema::BasePlusRate,
      style: :base_plus_rate,
      base:  30,
      rate:  "0.029".to_d, # 2.9% of total
    )

    class << self
      def id; :stripe; end

      def supported_payment_methods
        [ "credit card" ]
      end

      def place_order(buyer_organization:, user:, order_params:, cart:)
        PlaceStripeOrder.perform(payment_provider: :stripe, 
                                 entity: buyer_organization, 
                                 buyer: user,
                                 order_params: order_params, 
                                 cart: cart)
      end

      def translate_status(charge:, cart:nil, payment_method:nil)
        return 'failed' if charge.nil?
        case charge.status
        when 'pending'   then 'pending'
        when 'succeeded' then 'paid'
        else
          'failed'
        end
      end

      def charge_for_order(amount:, bank_account:, market:, order:, buyer_organization:)
        amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)
        customer = buyer_organization.stripe_customer_id
        source = bank_account.stripe_id
        destination = market.stripe_account_id
        descriptor = market.on_statement_as
        
        fee_in_cents = PaymentProvider::FeeEstimator.estimate_payment_fee CreditCardFeeStructure, amount_in_cents

        # TODO: once we support ACH via Stripe, this branch will be needed for an alternate estimate of ACH fees:
        # fee_in_cents = if bank_account.credit_card?
        #                  estimate_credit_card_processing_fee_in_cents(amount_in_cents)
        #                else
        #                  estimate_ach_processing_fee_in_cents(amount_in_cents)
        #                end
        
        return ::Stripe::Charge.create(
          amount: amount_in_cents, 
          currency: 'usd', 
          source: source, 
          customer: customer,
          destination: destination, 
          statement_descriptor: descriptor,
          application_fee: fee_in_cents)
      end

      def fully_refund(charge:nil, payment:, order:)
        charge ||= ::Stripe::Charge.retrieve(payment.stripe_id)
        charge.refunds.create(refund_application_fee: true,
                              reverse_transfer: true,
                              metadata: { 'lo.order_id' => order.id,
                                          'lo.order_number' => order.order_number })
      end

      def store_payment_fees(order:)
        raise ".store_payment_fees not implemented for Stripe provider yet!"
        # total_fee = order.payments.where(payment_type: 'order').sum(:stripe_payment_fee)
        # total_fee_cents = ::Financials::MoneyHelpers.amount_to_cents(total_fee)
        # fees = distribute_fee_amongst_order_items(total_fee_cents, order)
        #
        # fee_payer = order.market.payment_fee_payer
        # order.items.each do |item|
        #   fee_cents = fees[item.id]
        #   fee = if fee_cents.nil?
        #           0.to_d
        #         else
        #           ::Financials::MoneyHelpers.cents_to_amount(fee_cents)
        #         end
        #   item.update :"payment_#{fee_payer}_fee" => fee
        # end
      end

      def create_order_payment(charge:, market_id:, bank_account:, payer:,
                                  payment_method:, amount:, order:, status:)
        raise ".create_order_payment not implemented for Stripe provider yet!"
        # args = {
        #   market_id: market_id,
        #   bank_account: bank_account,
        #   payer: payer,
        #   payment_method: payment_method,
        #   amount: amount,
        #   payment_type: 'order',
        #   orders: [order],
        #   status: status
        # }
        # case payment_provider
        # when 'balanced'
        #   args[:balanced_uri] = charge.try(:uri)
        # when 'stripe'
        #   args[:stripe_id] = charge.try(:id)
        #   args[:stripe_payment_fee] = get_stripe_application_fee_on_charge(charge)
        #
        # end
        # Payment.create(args)
      end

      def distribute_fee_amongst_order_items(total_fee_cents, order)
        order_total_cents = ::Financials::MoneyHelpers.amount_to_cents(order.gross_total)

        LargestRemainder.distribute_shares(
          to_distribute: total_fee_cents,
          total:         order_total_cents,
          items:         order.usable_items.inject({}) do |memo,item|
                           memo[item.id] = ::Financials::MoneyHelpers.amount_to_cents(item.gross_total)
                         end
        )
      end
    end
    
  end
end
