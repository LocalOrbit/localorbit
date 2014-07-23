class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.string   :name,                      null: false
      t.string   :code,                      null: false
      t.integer  :market_id
      t.datetime :start_date
      t.datetime :end_date
      t.string   :type,                      null: false
      t.decimal  :discount,                  precision: 10, scale: 2, null: false
      t.integer  :product_id
      t.integer  :category_id
      t.integer  :buyer_organization_id
      t.integer  :seller_organization_id
      t.decimal  :minimum_order_total,       precision: 10, scale: 2, default: 0.0, null: false
      t.decimal  :maximum_order_total,       precision: 10, scale: 2, default: 0.0, null: false
      t.integer  :maximum_uses,              default: 0, null: false
      t.integer  :maximum_organization_uses, default: 0, null: false

      t.timestamps

      t.index :code
    end
  end
end
