class AddAddItemPricingToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :add_item_pricing, :boolean, default: true
  end
end
