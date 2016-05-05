class AddProductFeeToMarket < ActiveRecord::Migration
  def change
    add_column :markets, :allow_product_fee, :boolean
  end
end
