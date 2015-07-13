module Orders
  class UnitPriceLogic
    class << self
      def prices(product, market, organization, time)
        Price.for_product_and_market_and_org_at_time(product, market, organization, time).order(:min_quantity)
      end

      def unit_price(product, market, organization, time, quantity)
        product_prices = prices(product, market, organization, time)
        if quantity.nil? || quantity <= 0
          product_prices.first
        else
          product_prices.select {|p| p.min_quantity <= quantity }.last
        end
      end
    end
  end
end
