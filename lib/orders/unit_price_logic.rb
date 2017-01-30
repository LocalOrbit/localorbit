module Orders
  class UnitPriceLogic
    class << self
      def prices(product, market, organization, time)
        price = Price.for_product_and_market_and_org_at_time(product, market, organization, time).order(:min_quantity)
        price_specific = Price.for_product_and_market_and_org_at_time_specific(product, market, organization, time).order(:min_quantity)
        if price.empty? && price_specific.empty?
          price = Price.for_product_and_market_and_org_at_time(product, market, organization, Time.current).order(:min_quantity)
          price_specific = Price.for_product_and_market_and_org_at_time_specific(product, market, organization, Time.current).order(:min_quantity)
        end
        prices = []
        price.each do |p|
          skip=false
          price_specific.each do |q|
            if p.min_quantity == q.min_quantity
              prices << q
              skip = true
            end
          end
          if !skip
            prices << p
          end
        end

        prices
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
