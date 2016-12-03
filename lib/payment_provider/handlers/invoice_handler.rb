module PaymentProvider
  module Handlers
    class InvoiceHandler < AbstractMasterHandler

      def self.invoice_payment_succeeded(event_params)
        return if Payment.where(stripe_id: event_params[:payment]).any?
        return unless event_params.try(:subscription)

        # If this is for a valid subscriber...
        raise "Missing subscriber" unless subscriber = Market.where(stripe_customer_id: event_params[:customer]).first

        # ...paid with a credit card on file...
        charge = Stripe.get_charge(event_params[:payment])
        raise "Card not on file" unless bank_account = BankAccount.where(stripe_id: charge.source.id).first

        # ...then create a payment record:
        Payment.create(self.payment_params(subscriber, bank_account, event_params))

        # KXM messaging
      end

      def self.invoice_payment_failed(event_params)
        return unless event_params.try(:subscription)

        # If this is for a valid subscriber...
        raise "Missing subscriber" unless subscriber = Market.where(stripe_customer_id: event_params[:customer]).first

        # ...reflecting a credit card on file...
        charge = Stripe.get_charge(event_params[:payment])
        raise "Card not on file" unless bank_account = BankAccount.where(stripe_id: charge.source.id).first

        # ...then upsert a payment...
        payment = Payment.where(stripe_id: event_params[:payment]).first || Payment.create(self.payment_params(subscriber, bank_account, event_params))
        # ...and fail it
        payment.failed
      end

      private

      # Upsert and return an event log record
      def self.event_log_record(event)
        # Unique constraint on 'event_id' should ensure the first record is the correct record
        e = Event.where(event_id: event.id).first || Event.create(event_id: event.id, stripe_customer_id: event.data.object.customer, payload: event.to_json)
      end

      # Build and return a Payment hash
      def self.payment_params(subscriber, bank_account, event_params)
        # Research actual status when event_params[:paid] <> true.
        status = event_params[:paid] == true ? 'paid' : 'TBD'
        {
          payment_type: 'service',
          amount: event_params[:total],
          created_at: event_params[:date],
          updated_at: event_params[:date],
          status: status,
          payer_id: subscriber.organization_id,
          payer_type: 'Organization',
          market_id: subscriber.id,
          bank_account_id: bank_account.id,
          stripe_id: event_params[:payment],
          payment_provider: 'stripe',
          organization_id: subscriber.organization_id,
        }
      end

    end
  end
end
