module Search
  module MarketAndOrganization
    def market_id
      @query[:market_id_eq].to_s
    end

    def selling_markets
      @user.managed_markets.order(:name)
    end

    def organization_id
      @query[:organization_id_eq].to_s
    end

    def buyer_organizations
      base_scope = Order.orders_for_seller(@user).joins(:organization)

      if @filtered_market.present?
        base_scope.where(market_id: @filtered_market)
      else
        base_scope
      end.map(&:organization).uniq
    end
  end
end
