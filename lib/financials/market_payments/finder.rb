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

          # seller_orders = find_payable_seller_orders(as_of: as_of, seller_id: seller_id, order_id: order_id)
          #
          # # Group by seller_id,market_id  # .... market_id really? is important?
          # seller_sections = seller_orders.group_by(&:seller_id).map do |_, sos| 
          #   ::Financials::SellerPayments::Builder.build_seller_section( 
          #     seller_organization: sos.first.seller,
          #     seller_orders: sos
          #   )
          # end.sort_by do |section|
          #   section[:seller_name]
          # end
          #
          # return SchemaValidation.validate!([MarketSection], [])
        end
      end
    end
  end
end
