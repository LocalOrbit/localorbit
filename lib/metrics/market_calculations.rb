module Metrics
  class MarketCalculations < Base
    BASE_SCOPE = Market.where.not(id: TEST_MARKET_IDS).uniq
    METRICS = {
      total_markets: {
        title: "Total Markets",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      live_markets: {
        title: "Live Markets",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      live_markets_percent_growth: {
        title: "Live Markets % Growth",
        calculation: :percent_growth,
        calculation_arg: :live_markets,
        format: :percent
      },
      active_markets: {
        title: "Active Markets",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      active_markets_percent_growth: {
        title: "Active Markets % Growth",
        calculation: :percent_growth,
        calculation_arg: :active_markets,
        format: :percent
      },
      # allow_credit_cards is the admin setting which when
      # false trumps the default_allow_credit_cards setting
      credit_card_markets: {
        title: "Markets Using Credit Cards",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      credit_card_markets_percent_growth: {
        title: "Markets Using Credit Cards % Growth",
        calculation: :percent_growth,
        calculation_arg: :credit_card_markets,
        format: :percent
      },
      ach_markets: {
        title: "Markets Using ACH",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      ach_markets_percent_growth: {
        title: "Markets Using ACH % Growth",
        calculation: :percent_growth,
        calculation_arg: :ach_markets,
        format: :percent
      },
      lo_payment_markets: {
        title: "Markets Using LO Payments",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      lo_payment_markets_percent_growth: {
        title: "Markets Using LO Payments % Growth",
        calculation: :percent_growth,
        calculation_arg: :lo_payment_markets,
        format: :percent
      },
      start_up_markets: {
        title: "Markets On Start Up Plan",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      start_up_markets_percent_growth: {
        title: "Start Up Plan Markets % Growth",
        calculation: :percent_growth,
        calculation_arg: :start_up_markets,
        format: :percent
      },
      grow_markets: {
        title: "Markets On Grow Plan",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      grow_markets_percent_growth: {
        title: "Growth Plan Markets % Growth",
        calculation: :percent_growth,
        calculation_arg: :grow_markets,
        format: :percent
      },
      automate_markets: {
        title: "Markets On Automate Plan",
        scope: Market,
        calculation: :metric,
        format: :integer
      },
      automate_markets_percent_growth: {
        title: "Automate Plan Markets % Growth",
        calculation: :percent_growth,
        calculation_arg: :automate_markets,
        format: :percent
      },
    }
  end
end

Metrics::Base.register_metrics(Metrics::MarketCalculations::METRICS)
