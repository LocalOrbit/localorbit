module Metrics
  class PriceHistory < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Price"
    @@base_scope = ::Price.where.not(market_id: MetricsPresenter::TEST_MARKET_IDS).uniq
    @@metrics = {
      total_price_count: {
        calculation: :count,
        scope: @@base_scope,
        group: "markets.id",
        joins: { product: { organization: :markets } },
        model_type: "Market"
      },
      total_price_sum: {
        calculation: :sum,
        calculation_arg: :sale_price,
        scope: @@base_scope,
        group: "markets.id",
        joins: { product: { organization: :markets } },
        model_type: "Market"
      }
    }
  end
end
