class AddRequirePurchaseOrdersToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :require_purchase_orders, :boolean, default: false, null: false
  end
end
