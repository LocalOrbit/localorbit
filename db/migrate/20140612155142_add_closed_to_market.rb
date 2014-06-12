class AddClosedToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :closed, :boolean, default: false
  end
end
