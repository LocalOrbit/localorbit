module Role
  module MarketManager
    extend ActiveSupport::Concern

    def admin?
      false
    end

    def can_manage_market?(market)
      market.managers.include?(self)
    end

    def can_manage_organization?(org)
      managed_organizations.include?(org)
    end

    def managed_organizations
      market_ids = managed_markets.pluck(:id)
      Organization.joins(:market_organizations).where(market_organizations: {market_id: market_ids})
    end

    def managed_products
      managed_organizations.joins(:products)
    end
  end
end
