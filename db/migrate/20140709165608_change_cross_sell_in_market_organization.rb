class ChangeCrossSellInMarketOrganization < ActiveRecord::Migration
  class Market < ActiveRecord::Base
  end

  class Organization < ActiveRecord::Base
    has_many :market_organizations
    has_many :markets, -> { where(market_organizations: {cross_sell: false}) }, through: :market_organizations
  end

  class MarketOrganization < ActiveRecord::Base
    belongs_to :market
    belongs_to :organization
  end

  def up
    add_column(:market_organizations, :cross_sell_origin_market_id, :integer, default: nil)

    MarketOrganization.where(cross_sell: true).each do |mo|
      org = mo.organization
      origin = org.markets.first

      begin
        mo.update!(cross_sell_origin_market_id: origin.id)
      rescue Exception => e
        puts "Could not update the MarketOrganization id:#{mo.id}"
        p e
      end
    end

    remove_column(:market_organizations, :cross_sell)
  end

  def down
    add_column(:market_organizations, :cross_sell, :boolean, default: false)

    MarketOrganization.where.not(cross_sell_origin_market_id: nil).update_all(cross_sell: true)

    remove_column(:market_organizations, :cross_sell_origin_market_id)
  end
end
