module PaymentProvider
  class Balanced
    class << self
      def id; :balanced; end

      def place_order(buyer_organization:, user:, order_params:, cart:)
        # raise "implement BalancedProvider!"
        PlaceOrder.perform(payment_provider: :balanced, entity: buyer_organization, buyer: user,
                           order_params: order_params, cart: cart)
      end
    end
  end
end
