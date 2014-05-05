class AddAllowCrossSellToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :allow_cross_sell, :boolean, default: false
  end
end
