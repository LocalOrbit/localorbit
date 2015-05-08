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

      def translate_status(charge:, amount:nil, payment_method:nil)
        if amount
          # ...happens during cart checkout
          if amount == 0 || payment_method == "credit card"
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
        amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)
        buyer_organization.balanced_customer.debit(
          amount: amount_in_cents,
          source_uri: bank_account.balanced_uri,
          description: "#{market.name} purchase",
          appears_on_statement_as: market.on_statement_as,
          meta: {'order number' => order.order_number}
        ) 
      end

      def fully_refund(charge:nil, payment:, order:)
        charge ||= ::Balanced::Debit.find(payment.balanced_uri)
        charge.refund
      end

      def store_payment_fees(order:)
        # Intentional no-op for Balanced provider.
      end

      def create_order_payment(charge:, market_id:, bank_account:, payer:,
                                  payment_method:, amount:, order:, status:)
        Payment.create(
          market_id: market_id,
          bank_account: bank_account,
          payer: payer,
          payment_method: payment_method,
          amount: amount,
          payment_type: 'order',
          orders: [order],
          status: status,
          balanced_uri: charge.try(:uri)
        )
      end

      def create_refund_payment(charge:, market_id:, bank_account:, payer:,
                                    payment_method:, amount:, order:, status:, refund:, parent_payment:)
        raise "create_refund_payment not implemented for Balanced yet!" 
        # args = {
        #   market_id: market_id,
        #   bank_account: bank_account,
        #   payer: payer,
        #   payment_method: payment_method,
        #   amount: amount,
        #   payment_type: 'order refund',
        #   orders: [order],
        #   parent_id: parent_payment.id,
        #   status: status
        # }
        # case payment_provider
        # when 'balanced'
        #   args[:balanced_uri] = refund.try(:uri)
        # when 'stripe'
        #   args[:stripe_id] = charge.try(:id)
        #   args[:stripe_refund_id] = refund.try(:id)
        #   parent_payment.update stripe_payment_fee: get_stripe_application_fee_on_charge(charge)
        # end
        # Payment.create(args)
      end

    end
  end
end
