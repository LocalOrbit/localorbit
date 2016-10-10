class AddRyoEligibleToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :ryo_eligible, :boolean, default: false, null: false
  end
end
