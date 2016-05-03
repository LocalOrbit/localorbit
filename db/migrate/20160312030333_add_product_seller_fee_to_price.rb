class AddProductSellerFeeToPrice < ActiveRecord::Migration
  def change
    add_column :prices, :product_fee_pct, :decimal, precision: 5, scale: 3, default: 0.0, null: false
  end
end
