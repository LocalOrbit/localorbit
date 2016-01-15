module Search
  module MarketAndOrganization
    def market_id
      @query[:market_id_in].to_a
    end

    def selling_markets
      @user.markets.order(:name)
    end

    def organization_id
      @query[:organization_id_in].to_a
    end

    def buyer_organizations
      if @filtered_market.present?
        result = @user.managed_organizations_within_market_including_crossellers(@filtered_market)
      else
        result = @user.managed_organizations_including_cross_sellers
      end
      if !result.is_a?(Array)
        result.order(:name)
      end
      result
    end

    def seller_organizations
      if @filtered_organization.present?
        buyer_organizations.where(@filtered_organization)
      elsif buyer_organizations.nil?
        buyer_organizations.where(can_sell: true)
      else
        @user.managed_organizations.where(id: buyer_organizations.map(&:id))
      end
    end
  end
end
