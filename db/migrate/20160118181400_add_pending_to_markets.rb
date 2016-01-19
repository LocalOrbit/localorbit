class AddPendingToMarkets < ActiveRecord::Migration
=begin
	# Auto-generated code - here for temp reference
  def change
    add_column :markets, :pending, :boolean
  end
=end
	class Market < ActiveRecord::Base
	end

	def up
		change_table :markets do |t|
			t.boolean :pending, :default => false
		end
		Market.reset_column_information
		Market.update_all ["pending = ?", false]
	end

	def down
		remove_column :markets, :pending
	end
end
