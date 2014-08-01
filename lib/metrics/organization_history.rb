module Metrics
  class OrganizationHistory < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Organization"
    @@base_scope = ::Organization.where.not(id: MetricsPresenter::TEST_ORG_IDS).uniq
    @@metrics = {
      total_buyer_only:   { scope: self.base_scope.where(can_sell: false) },
      total_sellers:      { scope: self.base_scope.where(can_sell: true) },
      total_buyers:       { scope: ::Organization.where(::Organization.arel_table[:id].in(self.base_scope.select(:id).where(can_sell: false).union(self.base_scope.select(:id).joins(:orders)))) },
      total_buyer_orders: { scope: self.base_scope.joins(:orders) }
    }
  end
end
