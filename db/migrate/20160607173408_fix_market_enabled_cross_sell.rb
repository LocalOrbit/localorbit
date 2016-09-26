class FixMarketEnabledCrossSell < ActiveRecord::Migration
  def change
	rename_column :markets, :market_enabled_cross_sell, :self_enabled_cross_sell
  end
end
