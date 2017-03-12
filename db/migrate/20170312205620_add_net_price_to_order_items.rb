class AddNetPriceToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :net_price, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
