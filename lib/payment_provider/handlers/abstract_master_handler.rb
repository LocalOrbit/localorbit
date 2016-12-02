module PaymentProvider
  module Handlers
    class AbstractMasterHandler

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

        Rails.logger.info "Handling '#{params[:event_type]}' event. Event: #{e.inspect}"

        self.public_send(params[:event_type], event_data)

        event_log.update(successful_at: Time.current.end_of_minute) if not event_log.successful_at

      rescue Exception => e
        error_info = ErrorReporting.interpret_exception(e, "Error handling #{self.name} event from Stripe", {params: params})
        Honeybadger.notify_or_ignore(error_info[:honeybadger_exception])
        Rails.logger.error "Error handling event. Exception: #{e.inspect} Params: #{params.inspect}"

        raise e if e.message == "event_log_record must be defined in handler sub class"
      end

      private

      # Upsert and return an event log record
      def self.event_log_record(event) 
        raise "event_log_record must be defined in handler sub class" 
      end

    end
  end
end
