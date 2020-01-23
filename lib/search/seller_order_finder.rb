module Search
  class SellerOrderFinder

    def initialize(seller:, query:)
      @seller = seller
      scope = Order.payable_to_sellers(seller_organization_id: seller.id).
                where(market_id: query[:market_id])

      @q = scope.search(Search::QueryDefaults.new(query[:q] || {}, "placed_at").query)
    end

    def orders
      q.result
    end

    private

    attr_reader :q, :seller

  end
end
