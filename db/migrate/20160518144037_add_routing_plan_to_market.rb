class AddRoutingPlanToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :routing_plan, :boolean, default: false
  end
end
