module Metrics
  class OrganizationCalculations < Base
    cattr_accessor :base_scope, :metrics, :model_name

    BASE_SCOPE = Organization.where.not(id: TEST_ORG_IDS).uniq
    MODEL_NAME = BASE_SCOPE.name
    METRICS = {
      total_organizations: {
        title: "Total Organizations",
        scope: BASE_SCOPE,
        attribute: :created_at,
        calculation: :window,
        format: :integer
      },
      total_buyer_only: {
        title: "Total Buyers Only",
        scope: Organization,
        calculation: :metric,
        format: :integer
      },
      # union of all buyers + any seller that has bought
      total_buyers: {
        title: "Total Buyers",
        scope: Organization,
        calculation: :metric,
        format: :integer
      },
      total_buyers_percent_growth: {
        title: "Total Buyers % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_buyers,
        format: :percent
      },
      total_sellers: {
        title: "Total Sellers",
        scope: Organization,
        calculation: :metric,
        format: :integer
      },
      total_sellers_percent_growth: {
        title: "Total Sellers % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_sellers,
        format: :percent
      },
    }
  end
end

Metrics::Base.register_metrics(Metrics::OrganizationCalculations::METRICS)
