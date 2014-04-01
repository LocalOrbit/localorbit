class RenameOrderItemsFeeColumns < ActiveRecord::Migration
  def change
    rename_column :order_items, "market_fees",            "market_seller_fee"
    rename_column :order_items, "localorbit_seller_fees", "local_orbit_seller_fee"
    rename_column :order_items, "localorbit_market_fees", "local_orbit_market_fee"
    rename_column :order_items, "payment_seller_fees",    "payment_seller_fee"
    rename_column :order_items, "payment_market_fees",    "payment_market_fee"
  end
end
