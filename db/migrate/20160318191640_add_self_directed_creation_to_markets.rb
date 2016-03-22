class AddSelfDirectedCreationToMarkets < ActiveRecord::Migration
	class Market < ActiveRecord::Base
	end

	def up
		change_table :markets do |t|
			t.boolean :self_directed_creation, :default => false
		end
		Market.reset_column_information
		Market.update_all ["self_directed_creation = ?", false]
	end

	def down
		remove_column :markets, :self_directed_creation
	end
end
