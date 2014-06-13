class AddIndexes < ActiveRecord::Migration
  def change
    add_index :deliveries, :delivery_schedule_id
    add_index :deliveries, :deliver_on
    add_index :deliveries, :cutoff_time

    add_index :delivery_schedules, :deleted_at
    add_index :delivery_schedules, [:market_id, :deleted_at]

    add_index :locations, :deleted_at
    add_index :locations, [:organization_id, :deleted_at]

    add_index :lots, :good_from
    add_index :lots, :expires_at
    add_index :lots, [:good_from, :expires_at]
    add_index :lots, [:product_id, :good_from, :expires_at]

    add_index :managed_markets, :user_id
    add_index :managed_markets, :market_id
    add_index :managed_markets, [:user_id, :market_id]

    add_index :market_addresses, [:market_id, :deleted_at]

    add_index :market_cross_sells, :source_market_id
    add_index :market_cross_sells, :destination_market_id
    add_index :market_cross_sells, [:source_market_id, :destination_market_id], name: "index_market_cross_sells_on_src_market_id_and_dest_market_id"

    add_index :market_organizations, :market_id
    add_index :market_organizations, :organization_id
    add_index :market_organizations, [:market_id, :organization_id]

    add_index :markets, :name

    add_index :order_item_lots, :order_item_id
    add_index :order_item_lots, :lot_id
    add_index :order_item_lots, [:order_item_id, :lot_id]

    add_index :order_items, :product_id
    add_index :order_items, [:order_id, :product_id]

    add_index :order_payments, [:order_id, :payment_id]

    add_index :orders, :organization_id
    add_index :orders, :delivery_id
    add_index :orders, :placed_by_id

    add_index :organizations, :name

    add_index :payments, [:payer_id, :payer_type]
    add_index :payments, :market_id
    add_index :payments, :bank_account_id

    add_index :product_deliveries, :product_id
    add_index :product_deliveries, :delivery_schedule_id
    add_index :product_deliveries, [:product_id, :delivery_schedule_id]

    add_index :products, :top_level_category_id

    add_index :promotions, :market_id
    add_index :promotions, :product_id
    add_index :promotions, [:market_id, :product_id]

    add_index :user_organizations, :user_id
    add_index :user_organizations, :organization_id
    add_index :user_organizations, [:user_id, :organization_id]


  end
end
