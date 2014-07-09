module Search
  class SellerPaymentGroupFinder
    attr_reader :q

    def initialize(user: user, query: query, current_market: current_market)
      scope = Order.payable_to_sellers

      @seller_id = query[:filtered_organization_id]
      @seller_id = @seller_id.to_i if @seller_id.present?

      if user.admin?
        query[:q] ||= {}.with_indifferent_access
        query[:q][:market_id_eq] ||= current_market.try(:id) || Market.order(:name).first.id
      else
        scope = scope.where(market_id: user.managed_markets.map(&:id))
      end

      @q = scope.search(Search::QueryDefaults.new(query[:q] || {}, "placed_at").query)
    end

    def payment_groups
      SellerPaymentGroup.for_scope(@q.result, @seller_id)
    end
  end
end
