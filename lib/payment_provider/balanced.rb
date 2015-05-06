module PaymentProvider
  class Balanced
    class << self
      def id; :balanced; end

      def supported_payment_methods
        [ "credit card", "ach" ]
      end

      def place_order(buyer_organization:, user:, order_params:, cart:)
        PlaceOrder.perform(payment_provider: :balanced, entity: buyer_organization, buyer: user,
                           order_params: order_params, cart: cart)
      end

      def translate_status(charge:, cart:, payment_method:)
        if cart
          # ...happens during cart checkout
          if cart.total == 0 || payment_method == "credit card"
            "paid"
          else
            "pending"
          end
        else
          # ...happens during update order
          case charge.try(:status)
          when "pending"
            "pending"
          when "succeeded"
            "paid"
          else
            "failed"
          end
        end
      end

      def charge_for_order(amount:, bank_account:, market:, order:, buyer_organization:)
        raise ".charge_for_order is not implemented yet for Balanced provider!"
      end


    end
  end
end
