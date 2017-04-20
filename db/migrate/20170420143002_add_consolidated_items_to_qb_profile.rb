class AddConsolidatedItemsToQbProfile < ActiveRecord::Migration
  def change
    add_column :qb_profiles, :consolidated_supplier_item_name, :string
    add_column :qb_profiles, :consolidated_supplier_item_id, :integer
    add_column :qb_profiles, :consolidated_buyer_item_name, :string
    add_column :qb_profiles, :consolidated_buyer_item_id, :integer
  end
end
