module Search
  module MarketAndOrganization
    def market_id
      @query[:market_id_eq].to_s
    end

    def selling_markets
      @user.markets.order(:name)
    end

    def organization_id
      @query[:organization_id_eq].to_s
    end

    def buyer_organizations
      if @filtered_market.present?
        @user.managed_organizations_within_market(@filtered_market)
      else
        @user.managed_organizations
      end
    end
  end
end
