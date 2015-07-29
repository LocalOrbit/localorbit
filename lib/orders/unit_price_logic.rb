module Orders
  class UnitPriceLogic
    class << self
      def prices(product, market, organization, time)
        Price.for_product_and_market_and_org_at_time(product, market, organization, time).order(:min_quantity)
      end

      def unit_price(product, market, organization, time, quantity)
        all_prices = prices(product, market, organization, time)
        special_prices, general_prices = all_prices.partition { |p| p.organization_id == organization.id }

        if quantity.nil? || quantity <= 0
          special_prices.first || general_prices.first
        else
          select_tiered_price(special_prices, quantity) || select_tiered_price(general_prices, quantity)
        end
      end

      private

      def select_tiered_price(ps, q)
         ps.select { |p| p.min_quantity <= q }.last
      end
    end
  end
end
