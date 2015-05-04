module PaymentProvider
  Implementations = {
    stripe: PaymentProvider::Stripe,
    balanced: PaymentProvider::Balanced
    # test: PaymentProvider::TestProvider
  }

  class << self

    def for(payment_provider_identifier)
      impl = Implementations[payment_provider_identifier.to_sym]
      return impl if impl
      raise "No PaymentProvider for #{payment_provider_identifier.inspect}"
    end

    def place_order(payment_provider, buyer_organization:, user:, order_params:, cart:)
      PaymentProvider.for(payment_provider).place_order( 
        buyer_organization: buyer_organization,
        user: user,
        order_params: order_params,
        cart: cart)

      # raise "implement me"
      # case payment_provider
      # when 'balanced'
      #   PlaceOrder.perform(payment_provider: payment_provider, entity: buyer_organization, buyer: user,
      #                      order_params: order_params, cart: cart)
      # when 'stripe'
      #   PlaceStripeOrder.perform(payment_provider: payment_provider, entity: buyer_organization, buyer: user,
      #                            order_params: order_params, cart: cart)
      # else
      #   raise "unknown payment provider: #{payment_provider}"
      # end
    end

  end
end
