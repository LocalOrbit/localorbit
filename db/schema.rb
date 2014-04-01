# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140401153649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_accounts", force: true do |t|
    t.string   "bank_name"
    t.string   "last_four"
    t.string   "account_type"
    t.string   "balanced_uri"
    t.integer  "bankable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "balanced_verification_uri"
    t.boolean  "verified",                  default: false, null: false
    t.string   "bankable_type"
  end

  add_index "bank_accounts", ["bankable_type", "bankable_id"], name: "index_bank_accounts_on_bankable_type_and_bankable_id", using: :btree

  create_table "cart_items", force: true do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity",   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree
  add_index "cart_items", ["product_id"], name: "index_cart_items_on_product_id", using: :btree

  create_table "carts", force: true do |t|
    t.integer  "market_id"
    t.integer  "organization_id"
    t.integer  "delivery_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "carts", ["delivery_id"], name: "index_carts_on_delivery_id", using: :btree
  add_index "carts", ["location_id"], name: "index_carts_on_location_id", using: :btree
  add_index "carts", ["market_id"], name: "index_carts_on_market_id", using: :btree
  add_index "carts", ["organization_id"], name: "index_carts_on_organization_id", using: :btree

  create_table "categories", force: true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
  end

  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id", "lft", "rgt"], name: "index_categories_on_parent_id_and_lft_and_rgt", using: :btree
  add_index "categories", ["parent_id", "lft"], name: "index_categories_on_parent_id_and_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree

  create_table "deliveries", force: true do |t|
    t.integer  "delivery_schedule_id"
    t.datetime "deliver_on"
    t.datetime "cutoff_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_schedules", force: true do |t|
    t.integer  "market_id"
    t.integer  "day"
    t.decimal  "fee"
    t.string   "fee_type"
    t.integer  "order_cutoff",                   default: 24, null: false
    t.boolean  "require_delivery"
    t.boolean  "require_cross_sell_delivery"
    t.integer  "seller_fulfillment_location_id"
    t.string   "seller_delivery_start"
    t.string   "seller_delivery_end"
    t.integer  "buyer_pickup_location_id"
    t.string   "buyer_pickup_start"
    t.string   "buyer_pickup_end"
    t.boolean  "market_pickup"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  add_index "delivery_schedules", ["market_id"], name: "index_delivery_schedules_on_market_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "name",                             null: false
    t.string   "address",                          null: false
    t.string   "city",                             null: false
    t.string   "state",                            null: false
    t.string   "zip",                              null: false
    t.integer  "organization_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default_billing",  default: false, null: false
    t.boolean  "default_shipping", default: false, null: false
    t.datetime "deleted_at"
    t.string   "phone"
    t.string   "fax"
  end

  add_index "locations", ["organization_id"], name: "index_locations_on_organization_id", using: :btree

  create_table "lots", force: true do |t|
    t.integer  "product_id"
    t.datetime "good_from"
    t.datetime "expires_at"
    t.integer  "quantity"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lots", ["product_id"], name: "index_lots_on_product_id", using: :btree

  create_table "managed_markets", force: true do |t|
    t.integer  "market_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "market_addresses", force: true do |t|
    t.string   "name",       null: false
    t.string   "address",    null: false
    t.string   "city",       null: false
    t.string   "state",      null: false
    t.string   "zip",        null: false
    t.integer  "market_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "phone"
    t.string   "fax"
  end

  add_index "market_addresses", ["market_id"], name: "index_market_addresses_on_market_id", using: :btree

  create_table "market_organizations", force: true do |t|
    t.integer  "market_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "markets", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.string   "timezone"
    t.boolean  "active",                                         default: false, null: false
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "facebook"
    t.string   "twitter"
    t.text     "profile"
    t.text     "policies"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_uid"
    t.string   "tagline"
    t.string   "background"
    t.string   "balanced_customer_uri"
    t.boolean  "balanced_underwritten",                          default: false, null: false
    t.decimal  "local_orbit_seller_fee", precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "local_orbit_market_fee", precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "market_seller_fee",      precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "transaction_seller_fee", precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "transaction_market_fee", precision: 5, scale: 3, default: 0.0,   null: false
  end

  add_index "markets", ["subdomain"], name: "index_markets_on_subdomain", using: :btree

  create_table "order_item_lots", force: true do |t|
    t.integer  "order_item_id"
    t.integer  "lot_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "seller_name"
    t.integer  "quantity"
    t.string   "unit"
    t.decimal  "discount",               precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "market_fees",            precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "localorbit_seller_fees", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "localorbit_market_fees", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "payment_seller_fees",    precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "payment_market_fees",    precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "unit_price",             precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: true do |t|
    t.integer  "organization_id"
    t.integer  "market_id"
    t.integer  "delivery_id"
    t.string   "order_number"
    t.datetime "placed_at"
    t.datetime "invoiced_at"
    t.datetime "invoice_due_date"
    t.decimal  "delivery_fees",             precision: 10, scale: 2
    t.string   "delivery_status"
    t.decimal  "total_cost",                precision: 10, scale: 2
    t.string   "delivery_address"
    t.string   "delivery_city"
    t.string   "delivery_state"
    t.string   "delivery_zip"
    t.string   "delivery_phone"
    t.string   "billing_organization_name"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.string   "billing_phone"
    t.string   "payment_status"
    t.string   "payment_method"
    t.string   "payment_note"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.boolean  "can_sell"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "who_story"
    t.text     "how_story"
    t.string   "photo_uid"
    t.string   "balanced_customer_uri"
    t.boolean  "balanced_underwritten", default: false, null: false
    t.string   "facebook"
    t.string   "twitter"
  end

  create_table "prices", force: true do |t|
    t.integer  "product_id"
    t.integer  "market_id"
    t.integer  "organization_id"
    t.integer  "min_quantity",                             default: 1, null: false
    t.decimal  "sale_price",      precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prices", ["market_id"], name: "index_prices_on_market_id", using: :btree
  add_index "prices", ["organization_id"], name: "index_prices_on_organization_id", using: :btree
  add_index "prices", ["product_id"], name: "index_prices_on_product_id", using: :btree

  create_table "products", force: true do |t|
    t.text     "name"
    t.integer  "category_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "who_story"
    t.text     "how_story"
    t.integer  "location_id"
    t.boolean  "use_simple_inventory",  default: true, null: false
    t.integer  "unit_id"
    t.integer  "top_level_category_id"
    t.string   "image_uid"
    t.datetime "deleted_at"
    t.text     "short_description"
    t.text     "long_description"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["location_id"], name: "index_products_on_location_id", using: :btree
  add_index "products", ["organization_id"], name: "index_products_on_organization_id", using: :btree

  create_table "sequences", force: true do |t|
    t.string  "name"
    t.integer "value", default: 0, null: false
  end

  add_index "sequences", ["name"], name: "index_sequences_on_name", unique: true, using: :btree

  create_table "units", force: true do |t|
    t.string   "singular"
    t.string   "plural"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "units", ["plural"], name: "index_units_on_plural", using: :btree

  create_table "user_organizations", force: true do |t|
    t.integer  "user_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.string   "name"
    t.integer  "invitations_count",      default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
