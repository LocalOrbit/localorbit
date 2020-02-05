module PaymentProvider
  module Handlers
    class InvoiceHandler < AbstractMasterHandler

      def self.invoice_payment_succeeded(stripe_invoice)
        return if Payment.where(stripe_id: stripe_invoice[:payment]).any?
        return unless stripe_invoice.try(:subscription)
        raise "Could not find subscriber organization with stripe_customer_id '#{stripe_invoice[:customer]}'" unless org = Organization.where(stripe_customer_id: stripe_invoice[:customer]).first

        payment = Payment.create(self.build_payment(org, stripe_invoice))

        subscriber = Stripe.get_stripe_customer(stripe_invoice[:customer])
        subscription = subscriber.subscriptions.retrieve(stripe_invoice[:subscription]) if subscriber.present?
        org.set_subscription(subscription) if org.respond_to?(:set_subscription) && subscription.present?

        recipients = self.org_managers(org)

        WebhookMailer.delay.successful_payment(org, stripe_invoice)
        PaymentMadeEmailConfirmation.perform(recipients: recipients, payment: payment)
      end

      def self.invoice_payment_failed(stripe_invoice)
        return unless stripe_invoice.try(:subscription)
        org = Organization.where(stripe_customer_id: stripe_invoice[:customer]).first
        raise "Could not find subscriber organization with stripe_customer_id '#{stripe_invoice[:customer]}'" unless org

        # Upsert payment...
        payment = Payment.where(stripe_id: stripe_invoice[:payment]).first ||
                    Payment.create(self.build_payment(org, stripe_invoice))
        # ...and fail it select status, count(status) from payments group by status;select status, count(status) from payments group by status;
        payment.fail!

        WebhookMailer.delay.failed_payment(org, stripe_invoice)
      end


      private

      def self.org_managers(organization)
        markets = Market.where(organization_id: organization.id)
        recipients = []
        markets.each do |market|
          recipients = recipients | market.managers.map(&:pretty_email)
        end

        recipients
      end

      # Upsert and return an event log record
      def self.event_log_record(event)
        # Unique constraint on 'event_id' should ensure the first record is the correct record
        e = Event.where(event_id: event.id).first || Event.create(event_id: event.id, stripe_customer_id: event.data.object.customer, payload: event.to_json, livemode: !!event.livemode)
      end

      # Build and return a Payment hash
      # KXM Stripe Webhook: Decouple this handler by calling CreateServicePayment (once it can handle receipt of the stripe invoice)
      def self.build_payment(subscriber, stripe_invoice)

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
          bankable_id: bankable.id,
          bankable_type: bankable.class.name,
          expiration_month: source[:exp_month],
          expiration_year: source[:exp_year],
        }
      end
    end
  end
end
