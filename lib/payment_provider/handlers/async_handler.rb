module PaymentProvider
  module Handlers
    class AsyncHandler
      HANDLER_IMPLS = {
        'transfer.paid' => PaymentProvider::Handlers::TransferPaid,
        'plan.created' => PaymentProvider::Handlers::PlanHandler,
        'invoice.payment_succeeded' => PaymentProvider::Handlers::InvoiceHandler,
        'invoice.payment_failed' => PaymentProvider::Handlers::InvoiceHandler
      }
      # 'charge.failed' => PaymentProvider::Handlers::ChargeHandler
      # 'customer.subscription.created' => PaymentProvider::Handlers::SubscriptionHandler,

      def call(event)
        handler = HANDLER_IMPLS[event.type]
        if handler
          params = handler.extract_job_params(event)
          Rails.logger.info "Enqueueing '#{event.type}' event. Stripe Event id: '#{event.id}'"
          handler.delay(:run_at => 1.minute.from_now).handle(params)
        end
      end
    end
  end
end
