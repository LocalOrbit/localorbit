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
        @user.managed_organizations_within_market_including_crossellers(@filtered_market)
      else
        @user.managed_organizations_including_cross_sellers
      end.order(:name)
    end

    def seller_organizations
      buyer_organizations.where(can_sell: true)
    end
  end
end
