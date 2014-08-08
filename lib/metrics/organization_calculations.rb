module Metrics
  class OrganizationCalculations < Base
    BASE_SCOPE = Organization.where.not(id: TEST_ORG_IDS).uniq
    METRICS = {
      total_organizations: {
        title: "Total Organizations",
        scope: Organization,
        calculation: :metric,
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
      active_users: {
        title: "Active Users",
        scope: Organization,
        calculation: :metric,
        format: :integer
      },
      total_buyer_orders: {
        title: "Buyers Placing Orders",
        scope: BASE_SCOPE.joins(:orders),
        attribute: "orders.placed_at",
        calculation: :count,
        format: :integer
      },
      total_buyer_orders_percent_growth: {
        title: "Buyers Placing Orders % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_buyer_orders,
        format: :percent
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::OrganizationCalculations::METRICS)
