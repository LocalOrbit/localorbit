module Metrics
  class PaymentCalculations < Base
    BASE_SCOPE = Payment.joins(:market).where.not(market_id: TEST_MARKET_IDS)
    MODEL_NAME = BASE_SCOPE.name
    METRICS = {
      total_service_fees: {
        title: "Total Service Fees",
        scope: BASE_SCOPE.where(payment_type: "service"),
        attribute: "payments.created_at",
        calculation: :sum,
        calculation_arg: :amount,
        format: :currency
      },
      total_service_fees_percent_growth: {
        title: "Total Service Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_service_fees,
        format: :percent
      },
      # Average LO Service Fees
      # Fees charged based on user's plan
      #
      # Payment#amount when Payment#payment_type  is "service"
      average_service_fees: {
        title: "Average Service Fees",
        scope: BASE_SCOPE.where(payment_type: "service"),
        attribute: "payments.created_at",
        calculation: :average,
        calculation_arg: :amount,
        format: :currency
      },
      average_service_fees_percent_growth: {
        title: "Average Service Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :average_service_fees,
        format: :percent
      },
      total_service_transaction_fees: {
        title: "Total Service & Transaction Fees",
        calculation: :ruby,
        calculation_arg: [:+, :total_service_fees, :total_transaction_fees],
        format: :currency
      },
      total_service_transaction_fees_percent_growth: {
        title: "Total Service & Transaction Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_service_transaction_fees,
        format: :percent
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::PaymentCalculations::METRICS)
