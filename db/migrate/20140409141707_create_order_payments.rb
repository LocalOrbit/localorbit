class CreateOrderPayments < ActiveRecord::Migration
  def change
    create_table :order_payments do |t|
      t.integer :payment_id
      t.integer :order_id

      t.index :payment_id
      t.index :order_id

      t.timestamps
    end
  end
end
