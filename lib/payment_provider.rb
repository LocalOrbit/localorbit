module PaymentProvider
  Implementations = {
    stripe: PaymentProvider::Stripe,
    balanced: PaymentProvider::Balanced
  }

  class << self

    def for(payment_provider_identifier)
      raise "No PaymentProvider... payment_provider_identifer can't be nil" if payment_provider_identifier.nil?
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
    end

  end
end
