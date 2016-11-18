module PaymentProvider
  module Handlers
    class InvoiceHandler
    # KXM Inheritance?  Where should the class reside?

      def self.extract_job_params(event)
        {
          event_type: event.type.tr('.','_'),
          event: event
        }
      end

      def self.handle(params)
        # KXM THis is the structure of the call, with params[:event_type] as the first parameter, the 'sub' parameters falling in line behind - the sub paramters remain to be defined...
        self.public_send(params[:event_type], params[:event])
        Rails.logger.info "Handling a successful invoice event. Params: #{params.inspect}"


      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
      end

      def self.invoice_payment_succeeded(event_params)

        # If this invoice is for a subscription...
        raise "Not a subscription" unless event_params.try(:subscription)

        # ... for a valid subscriber...
        raise "Missing subscriber" unless subscriber = Market.where(stripe_customer_id: event_params[:customer] )

        # ...paid with a credit card on file...
        charge = Stripe::Charge.retrieve(event_params[:payment])
        raise "Card not on file" unless bank_account = BankAccount.where(stripe_id: charge.source.id)

        # ...that isn't duplicate...
        raise "Duplicate payment" if Payment.where(stripe_id: event_params[:payment])

        # ...then create a payment record:
        Payment.create!(payment_type: 'service', amount: event_params[:total], created_at: event_params[:date], updated_at: event_params[:date], status: 'paid',payer_id: subscriber.organization_id, payer_type: 'Organization', market_id: subscriber.id, bank_account_id: bank_account.id, stripe_id: event_params[:payment], payment_provider: 'stripe', organization_id: subscriber.organization_id )

        Rails.logger.info "In plan_created method. New plan details: Name: #{name}, Created: #{created}, Stripe ID: #{stripe_id}"
      end

    end
  end
end
