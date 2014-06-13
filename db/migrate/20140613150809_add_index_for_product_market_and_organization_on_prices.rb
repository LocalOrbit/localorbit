class AddIndexForProductMarketAndOrganizationOnPrices < ActiveRecord::Migration
  def change
    add_index :prices, [:product_id, :market_id, :organization_id]
  end
end
