class MarketOrganization < ActiveRecord::Base
  audited allow_mass_assignment: true

  module AssociationScopes
    def including_deleted
      unscope(market_organizations: :deleted_at)
    end

    def excluding_deleted
      where(market_organizations: {deleted_at: nil})
    end

    def not_cross_selling
      where(market_organizations: {cross_sell_origin_market_id: nil})
    end

    def cross_selling
      where.not(market_organizations: {cross_sell_origin_market_id: nil})
    end

    def mo_join_market_id(market_id)
      where(market_organizations: {market_id: market_id})
    end
  end

  include SoftDelete

  belongs_to :market
  belongs_to :organization
  belongs_to :cross_sell_origin_market, class_name: :Market

  scope :cross_selling,     -> { where.not(cross_sell_origin_market_id: nil) }
  scope :not_cross_selling, -> { where(cross_sell_origin_market_id: nil) }
  scope :excluding_deleted, -> { where(deleted_at: nil) }
end
