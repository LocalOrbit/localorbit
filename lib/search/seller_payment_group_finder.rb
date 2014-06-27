module Search
  class SellerPaymentGroupFinder
    attr_reader :q

    def initialize(user: user, query: query)
      scope = Payment.payments_for_user(user)

      @seller_id = query[:filtered_organization_id]
      @seller_id = @seller_id.to_i if @seller_id.present?

      if user.admin?
        scope = scope.where(market_id: user.managed_markets.map(&:id))
      end

      @q = scope.search(Search::QueryDefaults.new(query[:q] || {}, 'placed_at').query)
    end

    def payment_groups
      SellerPaymentGroup.for_scope(@q.result, @seller_id)
    end
  end
end
