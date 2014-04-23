class AddLegacyIdToModels < ActiveRecord::Migration
  def change
    add_column :markets, :legacy_id, :integer
    add_column :organizations, :legacy_id, :integer
    add_column :market_addresses, :legacy_id, :integer
    add_column :delivery_schedules, :legacy_id, :integer
    add_column :locations, :legacy_id, :integer
    add_column :products, :legacy_id, :integer
    add_column :lots, :legacy_id, :integer
    add_column :prices, :legacy_id, :integer
    add_column :payments, :legacy_id, :integer
  end
end
