class AddSellersEditOrdersBooleanToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :sellers_edit_orders, :boolean, default: false, null: false
  end
end
