module Metrics
  class OrganizationHistory < OrganizationCalculations
    cattr_accessor :history_metrics, :model_name

    @@model_name = BASE_SCOPE.name
    @@history_metrics = {
      total_buyer_only: { scope: BASE_SCOPE.where(can_sell: false) },
      total_sellers:    { scope: BASE_SCOPE.where(can_sell: true) },
      total_buyers:     { scope: Organization.where(id: BASE_SCOPE.select(:id).where(can_sell: false).union(BASE_SCOPE.select(:id).joins(:orders)).pluck(:id)) },
      active_users:     { scope: BASE_SCOPE.joins(products: :lots).where(Arel::Nodes::Group.new(Lot.arel_table[:expires_at].eq(nil).or(Lot.arel_table[:expires_at].gteq(Time.zone.now)))).union(BASE_SCOPE.joins(:orders).where("orders.placed_at >= ?", Date.current.beginning_of_day)).uniq }
    }
  end
end
