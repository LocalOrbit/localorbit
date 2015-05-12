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
          payment_provider: self.id.to_s,
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

      def create_refund_payment(charge:, market_id:, bank_account:, payer:, payment_method:, amount:, order:, status:, refund:, parent_payment:)
        Payment.create(
          payment_provider: self.id.to_s,
          market_id: market_id,
          bank_account: bank_account,
          payer: payer,
          payment_method: payment_method,
          amount: amount,
          payment_type: 'order refund',
          orders: [order],
          parent_id: parent_payment.id,
          status: status,
          balanced_uri: refund.try(:uri)
        )
      end

      def find_charge(payment:)
        payment.balanced_transaction
      end

      def refund_charge(charge:, amount:, order:)
        amount_in_cents = ::Financials::MoneyHelpers.amount_to_cents(amount)
        charge.refund(amount: amount_in_cents)
      end

      def add_payment_method(type:, entity:, bank_account_params:, representative_params:)
        # raise "add_payment_method not implemented for PaymentProvider::Balanced!"
        params = {
          entity: entity, 
          bank_account_params: bank_account_params, 
          representative_params: representative_params
        }
        if type == "card"
          AddBalancedCreditCardToEntity.perform(params)
        else
          AddBalancedBankAccountToEntity.perform(params)
        end
      end

    end
  end
end
