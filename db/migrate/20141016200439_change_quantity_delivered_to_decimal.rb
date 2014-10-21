class ChangeQuantityDeliveredToDecimal < ActiveRecord::Migration
  def up
    change_column :order_items, :quantity_delivered, :decimal, precision: 10, scale: 2
  end
  def down
    change_column :order_items, :quantity_delivered, :integer
  end
end
