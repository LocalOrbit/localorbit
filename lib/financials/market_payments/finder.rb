module Financials
  module MarketPayments
    class Finder
      class << self
        include ::Financials::MarketPayments::Schema

        def find_orders_with_payable_market_fees(as_of:, market_id: nil, order_id: nil)
          Order.payable_market_fees(
            current_time: as_of,
            market_id: market_id,
            order_id: order_id
          ).preload(:items, :market)
        end
        
        # Returns an Array of Financials::SellerPayments::Schema::SellerSection 
        def find_market_payment_sections(as_of:, market_id: nil, order_id: nil)
          orders = find_orders_with_payable_market_fees(
            as_of: as_of,
            market_id: market_id,
            order_id: order_id)

          market_sections = orders.group_by(&:market).map do |market, os|
            ::Financials::MarketPayments::Builder.build_market_section(
              market: market,
              orders: os
            )
          end.sort_by do |section|
            section[:market_name]
          end

          return SchemaValidation.validate!([MarketSection], market_sections)
        end
      end
    end
  end
end
