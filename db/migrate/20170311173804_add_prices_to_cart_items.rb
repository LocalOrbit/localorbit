class AddPricesToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :net_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :cart_items, :sales_price, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :cart_items, :lot_id, :integer
  end
end
