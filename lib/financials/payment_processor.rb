module Financials
  class PaymentProcessor
    class << self
      include Financials::Schema

      def pay_and_notify(payment_config:, inputs:)
        SchemaValidation.validate!(Financials::PaymentMetadata::ConfigSchema, payment_config)

        payment_info = Financials::PaymentInfoConverter.send(
          payment_config[:payment_info_converter],
          inputs)

        if payment_info[:amount] == 0
          res = {
            status: :payment_skipped,
            message: "Payment skipped due to 0 amount",
            payment_info: payment_info
          }
          return SchemaValidation.validate!(Result, res)
        end

            
        payment_attrs = payment_config[:payment_base_attrs].
          merge(payment_info)

        payment = Financials::PaymentExecutor.execute_credit(
          payment_attributes: payment_attrs,
          description: payment_config[:description])

        res = nil
        if payment.status == "failed"
          res = {
            payment: payment,
            status: :payment_failed,
            message: "Payment failed",
          }
        else
          Financials::PaymentNotifier.send(
            payment_config[:payment_notifier],
            payment: payment)

          res = {
            payment: payment,
            status: :ok
          }
        end

        return SchemaValidation.validate!(Result, res)
      end

    end
    
    # Description of the result structure from .pay_and_notify
    Result = RSchema.schema {
      either(
        {
          :status  => enum([:ok]),
          :payment => Payment,
        },
        {
          :status      => enum([:payment_failed]),
          :message     => String,
          :payment     => Payment,
        },
        {
          :status       => enum([:payment_skipped]),
          :message      => String,
          :payment_info => Financials::Schema::PaymentInfo,
        }
      )
    }
  end
end
