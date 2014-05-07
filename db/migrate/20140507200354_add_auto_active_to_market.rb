class AddAutoActiveToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :auto_activate_organizations, :boolean, default: false
  end
end
