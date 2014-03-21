class AddBalancedUnderwrittenToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :balanced_underwritten, :boolean, default: false, null: false
  end
end
