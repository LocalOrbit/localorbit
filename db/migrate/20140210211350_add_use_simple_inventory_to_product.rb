class AddUseSimpleInventoryToProduct < ActiveRecord::Migration
  def change
    add_column :products, :use_simple_inventory, :boolean, default: true, null: false
  end
end
