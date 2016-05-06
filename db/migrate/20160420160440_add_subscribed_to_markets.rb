class AddSubscribedToMarkets < ActiveRecord::Migration
	class Market < ActiveRecord::Base
	end

	def up
		change_table :markets do |t|
			t.boolean :subscribed, :default => false
		end
		Market.reset_column_information
		Market.update_all ["subscribed = ?", false]
	end

	def down
		remove_column :markets, :subscribed
	end
end
