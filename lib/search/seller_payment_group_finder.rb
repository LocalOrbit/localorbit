module Search
  class SellerPaymentGroupFinder
    attr_reader :q

    def initialize(user: user, query: query_params)
      scope = Payment.payments_for_user(user)

      if user.admin?
        scope = scope.where(market_id: user.managed_markets_ids)
      end

      @q = scope.search(query[:q])
    end

    def payment_groups
      SellerPaymentGroup.for_scope(@q.result)
    end
  end
end
