class CreateOrderItemLots < ActiveRecord::Migration
  def change
    create_table :order_item_lots do |t|
      t.integer :order_item_id
      t.integer :lot_id
      t.integer :quantity

      t.timestamps
    end
  end
end
