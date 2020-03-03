class RemoveConsignment < ActiveRecord::Migration
  def change
    drop_table :batch_consignment_printable_errors do |t|
      t.integer  "batch_consignment_printable_id"
      t.string   "task"
      t.text     "message"
      t.text     "exception"
      t.text     "backtrace"
      t.integer  "order_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table "batch_consignment_printables" do |t|
      t.integer  "user_id"
      t.string   "pdf_uid"
      t.string   "pdf_name"
      t.string   "generation_status", default: "not_started", null: false
      t.decimal  "generation_progress", precision: 5, scale: 2, default: 0.0, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table "batch_consignment_printables_orders" do |t|
      t.integer  "batch_consignment_printable_id"
      t.integer  "order_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table "consignment_printables" do |t|
      t.integer  "user_id"
      t.string   "pdf_uid"
      t.string   "pdf_name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table "consignment_products" do |t|
      t.integer  "product_id",                  null: false
      t.integer  "consignment_product_id",      null: false
      t.integer  "consignment_organization_id", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    drop_table "consignment_transactions" do |t|
      t.string   "transaction_type"
      t.integer  "order_id"
      t.integer  "order_item_id"
      t.integer  "lot_id"
      t.datetime "delivery_date"
      t.integer  "product_id"
      t.integer  "quantity"
      t.integer  "assoc_order_id"
      t.integer  "assoc_order_item_id"
      t.integer  "assoc_lot_id"
      t.integer  "assoc_product_id"
      t.datetime "created_at"
      t.integer  "market_id"
      t.integer  "parent_id"
      t.decimal  "sale_price",          precision: 10, scale: 2, default: 0.0
      t.decimal  "net_price",           precision: 10, scale: 2, default: 0.0
      t.integer  "holdover_order_id"
      t.boolean  "master"
      t.integer  "child_lot_id"
      t.integer  "child_product_id"
      t.datetime "deleted_at"
      t.text     "notes"
    end

    remove_column :order_items, :po_lot_id, :integer
    remove_column :order_items, :po_ct_id, :integer
  end
end
