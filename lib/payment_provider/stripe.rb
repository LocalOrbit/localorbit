module PaymentProvider
  class Stripe
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
        raise "not done"
        # customer = buyer_organization.stripe_customer_id
        # source = bank_account.stripe_id
        # destination = market.stripe_account_id
        # descriptor = market.on_statement_as
        #
        #
        # fee = if bank_account.credit_card?
        #         PaymentProviders::Stripe::FeeStructure.estimate_credit_card_processing_fee(amount)
        #       else
        #         PaymentProviders::Stripe::FeeStructure.estimate_ach_processing_fee(amount)
        #       end
        #
        # charge = Stripe::Charge.create(amount: amount, currency: 'usd', 
        #                       source: source, customer: customer,
        #                       destination: destination, statement_descriptor: descriptor,
        #                       application_fee: fee)
        #
      end

    end
  end
end
