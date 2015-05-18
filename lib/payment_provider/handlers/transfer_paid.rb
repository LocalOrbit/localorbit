module PaymentProvider
  module Handlers
    class TransferPaid

      def self.extract_job_params(event)
        {
          transfer_id: event.data.object.id,
          amount_in_cents: event.data.object.amount,
          stripe_account_id: event.user_id
        }
      end

      def self.handle(transfer_id:, stripe_account_id:, amount_in_cents:)
        if stripe_account_id
          market = Market.where(stripe_account_id: stripe_account_id).first
          order_ids = PaymentProvider::Stripe.order_ids_for_market_payout_transfer(
            transfer_id: transfer_id, 
            stripe_account_id: stripe_account_id)
          payment = PaymentProvider::Stripe.create_market_payment(
            transfer_id: transfer_id, 
            market: market, 
            order_ids: order_ids, 
            status: 'paid', 
            amount: ::Financials::MoneyHelpers.cents_to_amount(amount_in_cents))
          PaymentMailer.payment_received(market.managers.to_a, payment.id)
        end
      end
    end
  end
end
