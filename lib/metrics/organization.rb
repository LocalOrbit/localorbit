module Metrics
  class Organization < Metrics::Base
    BASE_SCOPE = ::Organization.where.not(id: MetricsPresenter::TEST_ORG_IDS).uniq
    METRICS = {
      total_buyer_only:   BASE_SCOPE.where(can_sell: false),
      total_sellers:      BASE_SCOPE.where(can_sell: true),
      total_buyers:       ::Organization.where(::Organization.arel_table[:id].in(BASE_SCOPE.select(:id).where(can_sell: false).union(BASE_SCOPE.select(:id).joins(:orders)))),
      total_buyer_orders: BASE_SCOPE.joins(:orders)
    }.with_indifferent_access
  end
end
