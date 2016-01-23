class AddPlanToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :plan_id, :integer
  end
end
