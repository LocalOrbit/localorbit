class AddMarketFeePctToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :market_seller_fee_pct, :decimal, precision: 5, scale: 3
  end
end
