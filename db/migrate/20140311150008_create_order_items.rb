class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.integer :order_id
      t.integer :product_id
      t.string  :name
      t.string  :seller_name
      t.integer :quantity
      t.string  :unit
      t.decimal :discount,               precision: 10, scale: 2, default: 0, null: false
      t.decimal :market_fees,            precision: 10, scale: 2, default: 0, null: false
      t.decimal :localorbit_seller_fees, precision: 10, scale: 2, default: 0, null: false
      t.decimal :localorbit_market_fees, precision: 10, scale: 2, default: 0, null: false
      t.decimal :payment_seller_fees,    precision: 10, scale: 2, default: 0, null: false
      t.decimal :payment_market_fees,    precision: 10, scale: 2, default: 0, null: false
      t.decimal :unit_price,             precision: 10, scale: 2, default: 0, null: false

      t.timestamps
    end
  end
end
