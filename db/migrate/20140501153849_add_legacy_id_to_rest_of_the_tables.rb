class AddLegacyIdToRestOfTheTables < ActiveRecord::Migration
  def change
    add_column :orders, :legacy_id, :integer
    add_column :order_items, :legacy_id, :integer
    add_column :order_item_lots, :legacy_id, :integer
    add_column :deliveries, :legacy_id, :integer
    add_column :users, :legacy_id, :integer
  end
end
