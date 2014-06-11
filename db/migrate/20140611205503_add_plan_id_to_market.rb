class AddPlanIdToMarket < ActiveRecord::Migration
  class Market < ActiveRecord::Base; end

  def up
    add_column :markets, :plan_id, :integer
    Market.update_all(plan_id: Plan.find_by_name("Grow").id)
  end

  def down
    remove_column :markets, :plan_id
  end
end
