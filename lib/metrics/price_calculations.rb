module Metrics
  class PriceCalculations < Base
    BASE_SCOPE = Price.where.not(market_id: TEST_MARKET_IDS).uniq
    MODEL_NAME = BASE_SCOPE.name
    METRICS = {
      total_price_sum: {
        title: "Total Price Sum",
        scope: Metric.where(metric_code: "total_price_sum"),
        attribute: :effective_on,
        calculation: :sum,
        calculation_arg: :value,
        format: :currency
      },
      total_price_count: {
        title: "Total Price Count",
        scope: Metric.where(metric_code: "total_price_count"),
        attribute: :effective_on,
        calculation: :sum,
        calculation_arg: :value,
        format: :integer
      },
      average_price: {
        title: "Average Price",
        calculation: :ruby,
        calculation_arg: [:/, :total_price_sum, :total_price_count],
        format: :currency
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::PriceCalculations::METRICS)
