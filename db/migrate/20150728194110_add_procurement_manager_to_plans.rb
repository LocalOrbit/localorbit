class AddProcurementManagerToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :has_procurement_managers, :boolean, default: false, null: false
  end
end
