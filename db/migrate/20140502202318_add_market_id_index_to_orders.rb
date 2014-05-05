class AddMarketIdIndexToOrders < ActiveRecord::Migration
  def change
    add_index :orders, :market_id
  end
end
