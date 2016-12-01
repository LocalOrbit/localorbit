module PaymentProvider
  module Handlers
    class InvoiceHandler
    # KXM Inheritance?  Where should the class reside?

      def self.extract_job_params(event)
        {
          # This transforms the dot-notation event type to a string suitable for 'public_send'
          event_type: event.type.tr('.','_'),
          # event: event.data.object
          event: event
        }
      end

      def self.handle(params)
        # From APIDoc [http://apidock.com/ruby/Object/public_send]:
        # [public_send] Invokes the method identified by [parameter one], passing it any arguments specified...
        e = params[:event]
        binding.pry
        event_data = e.data.object
        event_log  = Event.create!(event_id: e.id, payload: e.to_json)

        self.public_send(params[:event_type], event_data)

        Rails.logger.info "Handling a successful invoice event. Params: #{params.inspect}"
        event_log.update(successful_at: Time.current.end_of_minute)

      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
        Rails.logger.error "Error handling invoice event. Exception: #{e.inspect} Params: #{params.inspect}"
        # raise e
      end

      def self.invoice_payment_succeeded(event_params)
        # If this is for a valid subscriber...
        raise "Missing subscriber" unless subscriber = Market.where(stripe_customer_id: event_params[:customer]).first

        # # ...being billed for a subscription...
        # raise "Not a subscription" unless event_params.try(:subscription)

        # ...paid with a credit card on file...
        charge = Stripe.get_charge(event_params[:payment])
        raise "Card not on file" unless bank_account = BankAccount.where(stripe_id: charge.source.id).first

        # ...that isn't duplicate...
        raise "Duplicate payment" if Payment.where(stripe_id: event_params[:payment]).any?

        # ...then create a payment record:
        Payment.create!(payment_type: 'service', amount: event_params[:total], created_at: event_params[:date], updated_at: event_params[:date], status: 'paid',payer_id: subscriber.organization_id, payer_type: 'Organization', market_id: subscriber.id, bank_account_id: bank_account.id, stripe_id: event_params[:payment], payment_provider: 'stripe', organization_id: subscriber.organization_id )

        Rails.logger.info "In invoice_payment_succeeded method. Stripe charge id: #{charge.id}"
      end

    end
  end
end
