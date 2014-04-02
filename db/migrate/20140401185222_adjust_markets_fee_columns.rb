class AdjustMarketsFeeColumns < ActiveRecord::Migration
  def change
    rename_column :markets, :transaction_seller_fee, :credit_card_seller_fee
    rename_column :markets, :transaction_market_fee, :credit_card_market_fee
    add_column :markets, :ach_seller_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :ach_market_fee, :decimal, precision: 5, scale: 3, default: 0.0, null: false
    add_column :markets, :ach_fee_cap,    :decimal, precision: 6, scale: 2, default: 8.0, null: false
  end
end
