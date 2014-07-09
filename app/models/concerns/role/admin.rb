module Role
  module Admin
    extend ActiveSupport::Concern

    def admin?
      true
    end

    def can_manage_market?(market)
      true
    end

    def can_manage_organization?(org)
      true
    end

    def managed_organizations
      Organization.all
    end

    def managed_products
      Product.visible.seller_can_sell.joins(organization: :market_organizations).where(market_organizations: {cross_sell: false})
    end

  end
end
