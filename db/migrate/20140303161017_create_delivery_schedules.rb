class CreateDeliverySchedules < ActiveRecord::Migration
  def change
    create_table :delivery_schedules do |t|
      t.references :market, index: true
      t.integer :day
      t.decimal :fee
      t.string  :fee_type
      t.integer :order_cutoff, null: false, default: 24
      t.boolean :require_delivery
      t.boolean :require_cross_sell_delivery
      t.integer :seller_fulfillment_location_id
      t.string  :seller_delivery_start
      t.string  :seller_delivery_end
      t.integer :buyer_pickup_location_id
      t.string  :buyer_pickup_start
      t.string  :buyer_pickup_end
      t.boolean :market_pickup

      t.timestamps
    end
  end
end
