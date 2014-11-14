class AddOrderPrintablesToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :order_printables, :boolean, default: false, null: false
    has_order_printables = Plan.where("name IN ('Grow', 'Automate')")
    has_order_printables.each {|plan| plan.update_column(:order_printables, true)}
  end

  def down
    remove_column :plans, :order_printables, :boolean, default: false, null: false
  end
end
