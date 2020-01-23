module PaymentProvider
  module Handlers
    class AsyncHandler
      HANDLER_IMPLS = {
        'payout.paid' => PaymentProvider::Handlers::PayoutHandler,
        'plan.created' => PaymentProvider::Handlers::PlanHandler,
        'invoice.payment_succeeded' => PaymentProvider::Handlers::InvoiceHandler,
        'invoice.payment_failed' => PaymentProvider::Handlers::InvoiceHandler
      }

      def call(event)
        raise RuntimeError.new 'Cannot run in Stripe livemode if not in production' if event.livemode && !Rails.env.production?
        ::Rails::logger.info("WEBHOOK: #{event.type} CONNECT: #{event.try(:account)} LIVEMODE: #{event.livemode}")
        handler = HANDLER_IMPLS[event.type]
        return unless handler
        Rollbar.info('webhook', event)

        params = handler.extract_job_params(event)
        Rails.logger.info "Enqueueing '#{event.type}' event. Stripe Event id: '#{event.id}'"
        handler.delay(run_at: 1.minute.from_now).handle(params)
      end
    end
  end
end
