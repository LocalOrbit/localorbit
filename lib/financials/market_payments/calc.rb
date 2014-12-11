module Financials
  module MarketPayments
    class Calc
      class << self
        def market_fee(order)
          DataCalc.sum_of_field(order.items, :market_seller_fee, default: 0.to_d)
        end

        def market_delivery_fee(order)
          market_share_of_fees = 1 - order.market.local_orbit_seller_and_market_fee_fraction
          order.delivery_fees * market_share_of_fees
        end

        def fee_owed_to_market(order)
          market_fee(order) + market_delivery_fee(order)
        end
      end
    end
  end
end
