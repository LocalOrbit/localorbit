module PaymentProvider
  module Handlers
    class ChargeHandler < AbstractMasterHandler

      def self.charge_failed(event_params)
        Rails.logger.info "Inside 'charge.failed' handler. Params: #{event_params.inspect}"
        # KXM messaging
      end

      private

      # Upsert and return an event log record
      def self.event_log_record(event)
        e = Event.where(event_id: event.id).first || Event.create!(event_id: event.id, payload: event.to_json)
        # e = Event.where(event_id: event.id).first || Event.create!(event_id: event.id, stripe_customer_id: event.data.object.customer, payload: event.to_json)
      end
      
    end
  end
end
