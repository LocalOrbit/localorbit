class AddMarketSellerFeePctToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :market_seller_fee_pct, :decimal, precision: 5, scale: 3
  end
end
