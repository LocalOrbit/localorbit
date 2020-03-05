class RemoveProcurementManagerFromPlans < ActiveRecord::Migration
  def change
    remove_column :plans, :has_procurement_managers, :boolean, default: false, null: false
  end
end
