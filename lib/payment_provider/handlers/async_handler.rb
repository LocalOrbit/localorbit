module PaymentProvider
  module Handlers
    class AsyncHandler
      HANDLER_IMPLS = {
        'transfer.paid' => PaymentProvider::Handlers::TransferPaid
      }

      def call(event)
        handler = HANDLER_IMPLS[event.type]
        if handler
          params = handler.extract_job_params(event)
          Rails.logger.info "Enqueueing job for #{event.type} stripe event with params: #{params.inspect}"
          handler.delay.handle(params)
        end
      end
    end
  end
end
