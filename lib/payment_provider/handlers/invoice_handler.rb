module PaymentProvider
  module Handlers
    class InvoiceHandler < AbstractMasterHandler

      def self.invoice_payment_succeeded(stripe_invoice)
        return if Payment.where(stripe_id: stripe_invoice[:payment]).any?
        return unless stripe_invoice.try(:subscription)

        Payment.create(self.build_payment(stripe_invoice))

        subscription = ::Stripe.get_stripe_subscription(stripe_invoice[:subscription])
        if subscription.present? then
          subscriber = Organization.where(stripe_customer_id: stripe_invoice[:customer]).first
          subscriber.set_subscription(subscription)) if subscriber.respond_to?(:set_subscription)
        end

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
        raise "Missing subscriber" unless subscriber = Organization.where(stripe_customer_id: stripe_invoice[:customer]).first

        charge = Stripe.get_charge(stripe_invoice[:charge])
        bank_account = BankAccount.where(stripe_id: charge.source.id).first || BankAccount.create(self.build_card(charge.source, subscriber))

        status = stripe_invoice[:paid] == true ? 'paid' : 'failed'
        {
          payment_provider: subscriber.payment_provider,
          payment_type: 'service',
          organization: subscriber,
          payer: subscriber,
          amount: ::Financials::MoneyHelpers.cents_to_amount(stripe_invoice[:total]),
          stripe_id: stripe_invoice[:charge],
          bank_account: bank_account,
          payment_method: bank_account.bank_account? ? "ach" : "credit card",
          status: status,
          payer_type: 'Organization',
          created_at: stripe_invoice[:date],
          updated_at: stripe_invoice[:date],
        }
      end

      def self.build_card(source, bankable)
        {
          bank_name: source[:brand],
          last_four: source[:last4],
          stripe_id: source[:id],
          account_type: source[:brand],
          bankable_id: bankable.id
          bankable_type: bankable.class.name,
          expiration_month: source[:exp_month],
          expiration_year: source[:exp_year],
        }
      end
    end
  end
end
