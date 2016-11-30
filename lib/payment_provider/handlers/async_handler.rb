module PaymentProvider
  module Handlers
    class AsyncHandler
      HANDLER_IMPLS = {
        'transfer.paid' => PaymentProvider::Handlers::TransferPaid,
        'plan.created' => PaymentProvider::Handlers::PlanHandler,
        'invoice.payment_succeeded' => PaymentProvider::Handlers::InvoiceHandler
        # 'invoice.payment_failed' => PaymentProvider::Handlers::InvoiceHandler
      }

      # TODO
      # 'customer.subscription.created' => PaymentProvider::Handlers::SubscriptionHandler,

      def call(event)
        handler = HANDLER_IMPLS[event.type]
        if handler
          Event.create!(event_id: event.id, payload: event.inspect)
          params = handler.extract_job_params(event)
          Rails.logger.info "Enqueueing job for #{event.type} stripe event with params: #{params.inspect}"
          handler.delay.handle(params)
        end
      end
    end
  end
end
