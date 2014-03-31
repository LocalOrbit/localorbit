class AddFeesToMarkets < ActiveRecord::Migration
  def change
    add_column :markets, :local_orbit_seller_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :local_orbit_market_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :market_seller_fee,      :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :transaction_seller_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :transaction_market_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
  end
end
