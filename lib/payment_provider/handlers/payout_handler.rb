module PaymentProvider
  module Handlers
    class PayoutHandler

      def self.extract_job_params(event)
        {
          payout_id: event.data.object.id,
          amount_in_cents: event.data.object.amount,
          stripe_account_id: event.account,
        }
      end

      def self.handle(payout_id:, stripe_account_id:, amount_in_cents:)
        if stripe_account_id and market = Market.where('stripe_account_id=? OR legacy_stripe_account_id=?',stripe_account_id,stripe_account_id).first
          order_ids = PaymentProvider::Stripe.order_ids_for_market_payout_transfer(
            payout_id: payout_id,
            stripe_account_id: stripe_account_id)
          payment = PaymentProvider::Stripe.create_market_payment(
            payout_id: payout_id,
            market: market,
            order_ids: order_ids,
            status: 'paid',
            amount: ::Financials::MoneyHelpers.cents_to_amount(amount_in_cents))

          ::Financials::PaymentNotifier.market_payment_received(payment: payment, async: false)

          nil
        end
      rescue StandardError => e
        params = {
          payout_id: payout_id,
          stripe_account_id: stripe_account_id,
          amount_in_cents: amount_in_cents
        }
        error_info = ErrorReporting.interpret_exception(e, "Error handling payout.paid event from Stripe", {params: params})
        Rollbar.error(e)
      end
    end
  end
end
