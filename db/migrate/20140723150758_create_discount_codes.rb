class CreateDiscountCodes < ActiveRecord::Migration
  def change
    create_table :discount_codes do |t|
      t.string :name,                       null: false
      t.string :code,                       null: false
      t.integer :market_id
      t.date :start_date
      t.date :end_date
      t.string :type,                       null: false
      t.decimal :discount,                  precision: 10, scale: 2
      t.integer :product_id
      t.integer :category_id
      t.integer :buyer_organization_id
      t.integer :seller_organization_id
      t.decimal :minimum_order_total,       precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :maximum_order_total,       precision: 10, scale: 2, default: 0.0, null: false
      t.integer :maximum_uses,              default: 0, null: false
      t.integer :maximum_organization_uses, default: 0, null: false

      t.timestamps
    end
  end
end
