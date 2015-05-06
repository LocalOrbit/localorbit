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
    end
  end
end
