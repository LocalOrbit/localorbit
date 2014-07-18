class AddDemoToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :demo, :boolean, default: false
  end
end
