class DefaultAltOrderPage < ActiveRecord::Migration
  def change
  	change_column :markets, :alternative_order_page, :boolean, :default => true
  end
end
