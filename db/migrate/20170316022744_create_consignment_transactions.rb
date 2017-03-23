class CreateConsignmentTransactions < ActiveRecord::Migration
  def change
    create_table :consignment_transactions do |t|
      t.string :transaction_type
      t.integer :order_id
      t.integer :order_item_id
      t.integer :lot_id
      t.datetime :delivery_date
      t.integer :product_id
      t.integer :quantity
      t.integer :assoc_order_id
      t.integer :assoc_order_item_id
      t.integer :assoc_lot_id
      t.integer :assoc_product_id
    end
  end
end
