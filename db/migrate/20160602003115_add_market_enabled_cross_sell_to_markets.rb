class AddMarketEnabledCrossSellToMarkets < ActiveRecord::Migration
	class Market < ActiveRecord::Base
	end

	def up
		change_table :markets do |t|
			t.boolean :market_enabled_cross_sell, :default => false
		end
		Market.reset_column_information
		Market.update_all ["market_enabled_cross_sell = ?", false]
	end

	def down
		remove_column :markets, :market_enabled_cross_sell
	end
end
