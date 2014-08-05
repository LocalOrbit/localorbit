module Metrics
  class PriceCalculations < Base
    cattr_accessor :base_scope, :metrics, :model_name

    BASE_SCOPE = Price.where.not(market_id: MetricsPresenter::TEST_MARKET_IDS).uniq
    MODEL_NAME = BASE_SCOPE.name
    METRICS = {
      total_price_count: {
        calculation: :count,
        scope: BASE_SCOPE,
        group: "markets.id",
        joins: { product: { organization: :markets } },
        model_type: "Market"
      },
      total_price_sum: {
        calculation: :sum,
        calculation_arg: :sale_price,
        scope: BASE_SCOPE,
        group: "markets.id",
        joins: { product: { organization: :markets } },
        model_type: "Market"
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::PriceCalculations::METRICS)
