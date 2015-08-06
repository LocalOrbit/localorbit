class UpdateOrderItemsQuantityToDecimal < ActiveRecord::Migration
  def up
    change_column :order_items, :quantity, :decimal, precision: 10, scale: 2, default: nil, null: true
  end

  def down
    change_column :order_items, :quantity, :integer
  end
end
