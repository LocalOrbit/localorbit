module Metrics
  class MarketHistory < MarketCalculations
    cattr_accessor :history_metrics, :model_name

    @@model_name = BASE_SCOPE.name
    @@history_metrics = {
      total_markets:        { scope: BASE_SCOPE },
      live_markets:         { scope: BASE_SCOPE.where(active: true) },
      active_markets:       { scope: BASE_SCOPE.joins(:orders) },
      credit_card_markets:  { scope: BASE_SCOPE.where(allow_credit_cards: true, default_allow_credit_cards: true) },
      ach_markets:          { scope: BASE_SCOPE.where(allow_ach: true, default_allow_ach: true) },
      lo_payment_markets:   { scope: BASE_SCOPE.where(BASE_SCOPE.arel_table[:allow_purchase_orders].eq(true).or(BASE_SCOPE.arel_table[:default_allow_purchase_orders].eq(true))) },
      start_up_markets:     { scope: BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Start Up")) },
      grow_markets:         { scope: BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Grow")) },
      automate_markets:     { scope: BASE_SCOPE.joins(:plan).where(plan_id: Plan.find_by_name("Automate")) }
    }

    STATES.each do |state|
      @@history_metrics["#{state.downcase}_markets"] = {
        scope: BASE_SCOPE.joins(:addresses).where(market_addresses: { state: state })
      }
    end
  end
end
