module Metrics
  class MarketHistory < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Market"
    @@base_scope = ::Market.where.not(id: MetricsPresenter::TEST_MARKET_IDS).uniq
    @@metrics = {
      live_markets:         { scope: self.base_scope.where(active: true) },
      active_markets:       { scope: self.base_scope.joins(:orders) },
      credit_card_markets:  { scope: self.base_scope.where(allow_credit_cards: true, default_allow_credit_cards: true) },
      ach_markets:          { scope: self.base_scope.where(allow_ach: true, default_allow_ach: true) },
      lo_payment_markets:   { scope: self.base_scope.where(self.base_scope.arel_table[:allow_purchase_orders].eq(true).or(self.base_scope.arel_table[:default_allow_purchase_orders].eq(true))) },
      start_up_markets:     { scope: self.base_scope.joins(:plan).where(plan_id: Plan.find_by_name("Start Up")) },
      grow_markets:         { scope: self.base_scope.joins(:plan).where(plan_id: Plan.find_by_name("Grow")) },
      automate_markets:     { scope: self.base_scope.joins(:plan).where(plan_id: Plan.find_by_name("Automate")) }
    }
  end
end
