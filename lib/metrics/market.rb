module Metrics
  class Market < Metrics::Base
    BASE_SCOPE = ::Market.where.not(id: MetricsPresenter::TEST_MARKET_IDS).uniq
    METRICS = {
      live_markets:         BASE_SCOPE.where(active: true),
      active_markets:       BASE_SCOPE.joins(:orders),
      credit_card_markets:  BASE_SCOPE.where(allow_credit_cards: true, default_allow_credit_cards: true),
      ach_markets:          BASE_SCOPE.where(allow_ach: true, default_allow_ach: true),
      lo_payment_markets:   BASE_SCOPE.where(allow_purchase_orders: true, default_allow_purchase_orders: true),
      start_up_markets:     BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Start Up")),
      grow_markets:         BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Grow")),
      automate_market:      BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Automate"))
    }.with_indifferent_access
  end
end
