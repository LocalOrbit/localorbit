class AddPackingLabelsToPlans < ActiveRecord::Migration
  def up
    add_column :plans, :packing_labels, :boolean, default: false, null: false
    has_packing_labels = Plan.where("name IN ('Grow', 'Automate')")
    has_packing_labels.each {|plan| plan.update_column(:packing_labels, true)}
  end

  def down
    remove_column :plans, :packing_labels, :boolean, default: false, null: false
  end
end
