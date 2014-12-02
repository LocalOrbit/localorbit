class AddSellersEditOrdersToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :sellers_edit_orders, :boolean, default: false, null: false
    has_sellers_edit_orders = Plan.where("name IN ('Grow', 'Automate')")
    has_sellers_edit_orders.each {|plan| plan.update_column(:sellers_edit_orders, true)}
  end

  def down
    remove_column :plans, :sellers_edit_orders, :boolean, default: false, null: false
  end
end
