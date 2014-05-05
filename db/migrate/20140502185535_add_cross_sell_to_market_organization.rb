class AddCrossSellToMarketOrganization < ActiveRecord::Migration
  def change
    add_column :market_organizations, :cross_sell, :boolean, default: false
  end
end
