module PaymentProvider
  module Handlers
    class InvoiceHandler < AbstractMasterHandler

      def self.invoice_payment_succeeded(stripe_invoice)
        # KXM !! Organization.plan_fee ought to be set in here somewhere...
        return if Payment.where(stripe_id: stripe_invoice[:payment]).any?
        return unless stripe_invoice.try(:subscription)

        Payment.create(self.build_payment(stripe_invoice))

        WebhookMailer.delay.successful_payment(subscriber, stripe_invoice)
      end

      def self.invoice_payment_failed(stripe_invoice)
        return unless stripe_invoice.try(:subscription)

        # Upsert payment...
        payment = Payment.where(stripe_id: stripe_invoice[:payment]).first || Payment.create(self.build_payment(stripe_invoice))
        # ...and fail it
        payment.failed

        WebhookMailer.delay.failed_payment(subscriber, stripe_invoice)
      end


      private

      # Upsert and return an event log record
      def self.event_log_record(event)
        # Unique constraint on 'event_id' should ensure the first record is the correct record
        e = Event.where(event_id: event.id).first || Event.create(event_id: event.id, stripe_customer_id: event.data.object.customer, payload: event.to_json, livemode: !!event.livemode)
      end

      # Build and return a Payment hash
      # KXM !! Decouple this handler by calling CreateServicePayment (once it can handle receipt of the stripe invoice)
      def self.build_payment(stripe_invoice)
        # KXM !! This will reference the Organization once the Market reference is confirmed depreciated
        raise "Missing subscriber" unless subscriber = Market.where(stripe_customer_id: stripe_invoice[:customer]).first

        charge = Stripe.get_charge(stripe_invoice[:charge])
        raise "Card not on file" unless bank_account = BankAccount.where(stripe_id: charge.source.id).first

        # KXM !! payment_provider references the Market payment provider right now...
        status = stripe_invoice[:paid] == true ? 'paid' : 'failed'
        {
          payment_provider: subscriber.payment_provider,
          payment_type: 'service',
          organization: subscriber.organization,
          payer: subscriber.organization,
          amount: ::Financials::MoneyHelpers.cents_to_amount(stripe_invoice[:total]),
          stripe_id: stripe_invoice[:charge],
          bank_account: bank_account,
          payment_method: bank_account.bank_account? ? "ach" : "credit card",
          status: status,
          payer_type: 'Organization',
          market: subscriber,
          created_at: stripe_invoice[:date],
          updated_at: stripe_invoice[:date],
        }
      end
    end
  end
end
