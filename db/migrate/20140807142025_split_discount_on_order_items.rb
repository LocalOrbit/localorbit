class SplitDiscountOnOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :discount_market, :decimal, precision: 10, scale: 2, null: false, default: 0
    rename_column :order_items, :discount, :discount_seller
  end
end
