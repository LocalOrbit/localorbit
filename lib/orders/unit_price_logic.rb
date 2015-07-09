module Orders
  class UnitPriceLogic
    class << self
      def prices(product, market, organization)
        product.prices_for_market_and_organization(market, organization)
      end

      def unit_price(product, market, organization, quantity)
        product_prices = prices(product, market, organization)
        if quantity.nil? || quantity <= 0
          product_prices.first
        else
          product_prices.select {|p| p.min_quantity <= quantity }.last
        end
      end
    end
  end
end
