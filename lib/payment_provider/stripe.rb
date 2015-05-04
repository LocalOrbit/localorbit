module PaymentProvider
  class Stripe
    class << self
      def place_order(buyer_organization:, user:, order_params:, cart:)
        raise "implement me"
      end
    end
  end
end
