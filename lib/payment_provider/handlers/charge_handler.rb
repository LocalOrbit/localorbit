module PaymentProvider
  module Handlers
    class ChargeHandler

      def self.extract_job_params(event)
        {
          # This transforms the dot-notation event type to a string suitable for 'public_send'
          event_type: event.type.tr('.','_'),
          event: event
        }
      end

      def self.handle(params)
        # From APIDoc [http://apidock.com/ruby/Object/public_send]:
        # [public_send] Invokes the method identified by [parameter one], passing it any arguments specified...
        e = params[:event]
        event_data = e.data.object
        event_log  = self.event_log_record(e)

        self.public_send(params[:event_type], event_data)

        event_log.update(successful_at: Time.current.end_of_minute) if not event_log.successful_at

      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
        Rails.logger.error "Error handling invoice event. Exception: #{e.inspect} Params: #{params.inspect}"

        # KXM ErrorReporting
        # KXM Honeybadger
      end

      def self.charge_failed(event_params)
        Rails.logger.info "Handling 'charge.failed' event. Params: #{event_params.inspect}"
        # KXM messaging
      end

      private

      # Upsert and return an event log record
      def self.event_log_record(event)
        e = Event.where(event_id: event.id).first || Event.create!(event_id: event.id, stripe_customer_id: event.data.object.customer, payload: event.to_json)
      end
      
    end
  end
end
