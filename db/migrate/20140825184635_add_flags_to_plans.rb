class AddFlagsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :promotions, :boolean, default: false, null: false
    add_column :plans, :advanced_pricing, :boolean, default: false, null: false
    add_column :plans, :advanced_inventory, :boolean, default: false, null: false
  end
end
