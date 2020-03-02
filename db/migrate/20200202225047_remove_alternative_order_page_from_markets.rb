class RemoveAlternativeOrderPageFromMarkets < ActiveRecord::Migration
  def change
    remove_column :markets, :alternative_order_page, :boolean, default: false, null: false
  end
end
