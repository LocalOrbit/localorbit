module PaymentProvider
  module Handlers
    class TransferPaid

      def self.extract_job_params(event)
        # TODO: maybe extract amount from event.data.object.amount
        {
          transfer_id: event.data.object.id,
          stripe_account_id: event.user_id
        }
      end

      def self.handle(transfer_id:, stripe_account_id:)
        if stripe_account_id
          market = Market.where(stripe_account_id: stripe_account_id).first
          order_ids = PaymentProvider::Stripe.order_ids_for_market_payout_transfer(
            transfer_id: transfer_id, stripe_account_id: stripe_account_id)
          transfer = PaymentProvider::Stripe.get_transfer(transfer_id: transfer_id) # XXX: just get the amount from event
          payment = PaymentProvider::Stripe.create_market_payment(
            stripe_transfer_id: transfer_id, market: market, order_ids: order_ids, 
            status: 'paid', amount: transfer.amount)
          PaymentMailer.payment_received(market.managers.to_a, payment.id)
        end
      end
    end
  end
end
