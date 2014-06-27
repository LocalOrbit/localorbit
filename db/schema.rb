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

ActiveRecord::Schema.define(version: 20140627171721) do

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
    t.integer  "expiration_month"
    t.integer  "expiration_year"
    t.string   "name"
    t.string   "notes"
    t.datetime "deleted_at"
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
    t.integer  "user_id"
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

  add_index "categories", ["depth"], name: "index_categories_on_depth", using: :btree
  add_index "categories", ["lft"], name: "index_categories_on_lft", using: :btree
  add_index "categories", ["parent_id", "lft", "rgt"], name: "index_categories_on_parent_id_and_lft_and_rgt", using: :btree
  add_index "categories", ["parent_id", "lft"], name: "index_categories_on_parent_id_and_lft", using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["rgt"], name: "index_categories_on_rgt", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deliveries", force: true do |t|
    t.integer  "delivery_schedule_id"
    t.datetime "deliver_on"
    t.datetime "cutoff_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
  end

  add_index "deliveries", ["cutoff_time"], name: "index_deliveries_on_cutoff_time", using: :btree
  add_index "deliveries", ["deliver_on"], name: "index_deliveries_on_deliver_on", using: :btree
  add_index "deliveries", ["delivery_schedule_id"], name: "index_deliveries_on_delivery_schedule_id", using: :btree

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
    t.integer  "legacy_id"
  end

  add_index "delivery_schedules", ["deleted_at"], name: "index_delivery_schedules_on_deleted_at", using: :btree
  add_index "delivery_schedules", ["market_id", "deleted_at"], name: "index_delivery_schedules_on_market_id_and_deleted_at", using: :btree
  add_index "delivery_schedules", ["market_id"], name: "index_delivery_schedules_on_market_id", using: :btree

  create_table "geocodes", force: true do |t|
    t.decimal "latitude",    precision: 15, scale: 12
    t.decimal "longitude",   precision: 15, scale: 12
    t.string  "query"
    t.string  "street"
    t.string  "locality"
    t.string  "region"
    t.string  "postal_code"
    t.string  "country"
    t.string  "precision"
  end

  add_index "geocodes", ["country"], name: "geocodes_country_index", using: :btree
  add_index "geocodes", ["latitude"], name: "geocodes_latitude_index", using: :btree
  add_index "geocodes", ["locality"], name: "geocodes_locality_index", using: :btree
  add_index "geocodes", ["longitude"], name: "geocodes_longitude_index", using: :btree
  add_index "geocodes", ["postal_code"], name: "geocodes_postal_code_index", using: :btree
  add_index "geocodes", ["precision"], name: "geocodes_precision_index", using: :btree
  add_index "geocodes", ["query"], name: "geocodes_query_index", unique: true, using: :btree
  add_index "geocodes", ["region"], name: "geocodes_region_index", using: :btree

  create_table "geocodings", force: true do |t|
    t.integer "geocodable_id"
    t.integer "geocode_id"
    t.string  "geocodable_type"
  end

  add_index "geocodings", ["geocodable_id"], name: "geocodings_geocodable_id_index", using: :btree
  add_index "geocodings", ["geocodable_type"], name: "geocodings_geocodable_type_index", using: :btree
  add_index "geocodings", ["geocode_id"], name: "geocodings_geocode_id_index", using: :btree

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
    t.integer  "legacy_id"
  end

  add_index "locations", ["deleted_at"], name: "index_locations_on_deleted_at", using: :btree
  add_index "locations", ["organization_id", "deleted_at"], name: "index_locations_on_organization_id_and_deleted_at", using: :btree
  add_index "locations", ["organization_id"], name: "index_locations_on_organization_id", using: :btree

  create_table "lots", force: true do |t|
    t.integer  "product_id"
    t.datetime "good_from"
    t.datetime "expires_at"
    t.integer  "quantity"
    t.string   "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
  end

  add_index "lots", ["expires_at"], name: "index_lots_on_expires_at", using: :btree
  add_index "lots", ["good_from", "expires_at"], name: "index_lots_on_good_from_and_expires_at", using: :btree
  add_index "lots", ["good_from"], name: "index_lots_on_good_from", using: :btree
  add_index "lots", ["product_id", "good_from", "expires_at"], name: "index_lots_on_product_id_and_good_from_and_expires_at", using: :btree
  add_index "lots", ["product_id"], name: "index_lots_on_product_id", using: :btree

  create_table "managed_markets", force: true do |t|
    t.integer  "market_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "managed_markets", ["market_id"], name: "index_managed_markets_on_market_id", using: :btree
  add_index "managed_markets", ["user_id", "market_id"], name: "index_managed_markets_on_user_id_and_market_id", using: :btree
  add_index "managed_markets", ["user_id"], name: "index_managed_markets_on_user_id", using: :btree

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
    t.integer  "legacy_id"
  end

  add_index "market_addresses", ["market_id", "deleted_at"], name: "index_market_addresses_on_market_id_and_deleted_at", using: :btree
  add_index "market_addresses", ["market_id"], name: "index_market_addresses_on_market_id", using: :btree

  create_table "market_cross_sells", force: true do |t|
    t.integer  "source_market_id"
    t.integer  "destination_market_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "market_cross_sells", ["destination_market_id"], name: "index_market_cross_sells_on_destination_market_id", using: :btree
  add_index "market_cross_sells", ["source_market_id", "destination_market_id"], name: "index_market_cross_sells_on_src_market_id_and_dest_market_id", using: :btree
  add_index "market_cross_sells", ["source_market_id"], name: "index_market_cross_sells_on_source_market_id", using: :btree

  create_table "market_organizations", force: true do |t|
    t.integer  "market_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cross_sell",      default: false
  end

  add_index "market_organizations", ["market_id", "organization_id"], name: "index_market_organizations_on_market_id_and_organization_id", using: :btree
  add_index "market_organizations", ["market_id"], name: "index_market_organizations_on_market_id", using: :btree
  add_index "market_organizations", ["organization_id"], name: "index_market_organizations_on_organization_id", using: :btree

  create_table "markets", force: true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.string   "timezone"
    t.boolean  "active",                                                default: false, null: false
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
    t.string   "background_image"
    t.string   "balanced_customer_uri"
    t.boolean  "balanced_underwritten",                                 default: false, null: false
    t.decimal  "local_orbit_seller_fee",        precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "local_orbit_market_fee",        precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "market_seller_fee",             precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "credit_card_seller_fee",        precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "credit_card_market_fee",        precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "ach_seller_fee",                precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "ach_market_fee",                precision: 5, scale: 3, default: 0.0,   null: false
    t.decimal  "ach_fee_cap",                   precision: 6, scale: 2, default: 8.0,   null: false
    t.integer  "po_payment_term"
    t.string   "photo_uid"
    t.boolean  "allow_credit_cards",                                    default: true
    t.boolean  "allow_purchase_orders",                                 default: true
    t.boolean  "allow_ach",                                             default: true
    t.boolean  "default_allow_purchase_orders",                         default: false
    t.boolean  "default_allow_credit_cards",                            default: true
    t.boolean  "default_allow_ach",                                     default: true
    t.integer  "legacy_id"
    t.string   "background_color"
    t.string   "text_color"
    t.boolean  "allow_cross_sell",                                      default: false
    t.boolean  "auto_activate_organizations",                           default: false
    t.integer  "plan_id"
    t.boolean  "closed",                                                default: false
  end

  add_index "markets", ["name"], name: "index_markets_on_name", using: :btree
  add_index "markets", ["subdomain"], name: "index_markets_on_subdomain", using: :btree

  create_table "newsletters", force: true do |t|
    t.string   "subject"
    t.text     "body"
    t.integer  "market_id"
    t.string   "image_uid"
    t.string   "header"
    t.boolean  "draft"
    t.date     "sent_on"
    t.boolean  "buyers"
    t.boolean  "sellers"
    t.boolean  "market_managers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "newsletters", ["market_id"], name: "index_newsletters_on_market_id", using: :btree

  create_table "order_item_lots", force: true do |t|
    t.integer  "order_item_id"
    t.integer  "lot_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
  end

  add_index "order_item_lots", ["lot_id"], name: "index_order_item_lots_on_lot_id", using: :btree
  add_index "order_item_lots", ["order_item_id", "lot_id"], name: "index_order_item_lots_on_order_item_id_and_lot_id", using: :btree
  add_index "order_item_lots", ["order_item_id"], name: "index_order_item_lots_on_order_item_id", using: :btree

  create_table "order_items", force: true do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "seller_name"
    t.integer  "quantity"
    t.string   "unit"
    t.decimal  "discount",               precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "market_seller_fee",      precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "local_orbit_seller_fee", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "local_orbit_market_fee", precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "payment_seller_fee",     precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "payment_market_fee",     precision: 10, scale: 2, default: 0.0, null: false
    t.decimal  "unit_price",             precision: 10, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "delivery_status"
    t.datetime "delivered_at"
    t.integer  "legacy_id"
    t.integer  "quantity_delivered"
  end

  add_index "order_items", ["order_id", "product_id"], name: "index_order_items_on_order_id_and_product_id", using: :btree
  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "order_payments", force: true do |t|
    t.integer  "payment_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_payments", ["order_id", "payment_id"], name: "index_order_payments_on_order_id_and_payment_id", using: :btree
  add_index "order_payments", ["order_id"], name: "index_order_payments_on_order_id", using: :btree
  add_index "order_payments", ["payment_id"], name: "index_order_payments_on_payment_id", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "organization_id"
    t.integer  "market_id"
    t.integer  "delivery_id"
    t.string   "order_number"
    t.datetime "placed_at"
    t.datetime "invoiced_at"
    t.datetime "invoice_due_date"
    t.decimal  "delivery_fees",             precision: 10, scale: 2
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
    t.integer  "placed_by_id"
    t.datetime "paid_at"
    t.integer  "legacy_id"
    t.datetime "deleted_at"
  end

  add_index "orders", ["delivery_id"], name: "index_orders_on_delivery_id", using: :btree
  add_index "orders", ["market_id"], name: "index_orders_on_market_id", using: :btree
  add_index "orders", ["organization_id"], name: "index_orders_on_organization_id", using: :btree
  add_index "orders", ["placed_by_id"], name: "index_orders_on_placed_by_id", using: :btree

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
    t.boolean  "display_facebook",      default: false
    t.boolean  "display_twitter",       default: false
    t.boolean  "allow_purchase_orders"
    t.boolean  "allow_credit_cards"
    t.boolean  "allow_ach"
    t.integer  "legacy_id"
    t.boolean  "show_profile",          default: true
    t.boolean  "active",                default: true
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", using: :btree

  create_table "payments", force: true do |t|
    t.integer  "payee_id"
    t.string   "payee_type"
    t.string   "payment_type",                             default: "order"
    t.decimal  "amount",          precision: 10, scale: 2, default: 0.0,     null: false
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "balanced_uri"
    t.integer  "legacy_id"
    t.integer  "payer_id"
    t.string   "payer_type"
    t.string   "payment_method"
    t.decimal  "refunded_amount", precision: 10, scale: 2, default: 0.0,     null: false
    t.integer  "market_id"
    t.integer  "bank_account_id"
  end

  add_index "payments", ["bank_account_id"], name: "index_payments_on_bank_account_id", using: :btree
  add_index "payments", ["market_id"], name: "index_payments_on_market_id", using: :btree
  add_index "payments", ["payee_id", "payee_type"], name: "index_payments_on_payee_id_and_payee_type", using: :btree
  add_index "payments", ["payer_id", "payer_type"], name: "index_payments_on_payer_id_and_payer_type", using: :btree

  create_table "plans", force: true do |t|
    t.string   "name"
    t.boolean  "discount_codes",     default: false
    t.boolean  "cross_selling",      default: false
    t.boolean  "custom_branding",    default: false
    t.boolean  "automatic_payments", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", force: true do |t|
    t.integer  "product_id"
    t.integer  "market_id"
    t.integer  "organization_id"
    t.integer  "min_quantity",                             default: 1, null: false
    t.decimal  "sale_price",      precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "legacy_id"
  end

  add_index "prices", ["market_id"], name: "index_prices_on_market_id", using: :btree
  add_index "prices", ["organization_id"], name: "index_prices_on_organization_id", using: :btree
  add_index "prices", ["product_id", "market_id", "organization_id"], name: "index_prices_on_product_id_and_market_id_and_organization_id", using: :btree
  add_index "prices", ["product_id"], name: "index_prices_on_product_id", using: :btree

  create_table "product_deliveries", force: true do |t|
    t.integer "product_id"
    t.integer "delivery_schedule_id"
  end

  add_index "product_deliveries", ["delivery_schedule_id"], name: "index_product_deliveries_on_delivery_schedule_id", using: :btree
  add_index "product_deliveries", ["product_id", "delivery_schedule_id"], name: "index_product_deliveries_on_product_id_and_delivery_schedule_id", using: :btree
  add_index "product_deliveries", ["product_id"], name: "index_product_deliveries_on_product_id", using: :btree

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
    t.string   "image_uid"
    t.integer  "top_level_category_id"
    t.datetime "deleted_at"
    t.text     "short_description"
    t.text     "long_description"
    t.boolean  "use_all_deliveries",    default: true
    t.integer  "legacy_id"
    t.string   "unit_description"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["location_id"], name: "index_products_on_location_id", using: :btree
  add_index "products", ["organization_id"], name: "index_products_on_organization_id", using: :btree
  add_index "products", ["top_level_category_id"], name: "index_products_on_top_level_category_id", using: :btree

  create_table "promotions", force: true do |t|
    t.integer  "market_id"
    t.integer  "product_id"
    t.string   "name"
    t.string   "title"
    t.text     "body"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_uid"
  end

  add_index "promotions", ["market_id", "product_id"], name: "index_promotions_on_market_id_and_product_id", using: :btree
  add_index "promotions", ["market_id"], name: "index_promotions_on_market_id", using: :btree
  add_index "promotions", ["product_id"], name: "index_promotions_on_product_id", using: :btree

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

  add_index "user_organizations", ["organization_id"], name: "index_user_organizations_on_organization_id", using: :btree
  add_index "user_organizations", ["user_id", "organization_id"], name: "index_user_organizations_on_user_id_and_organization_id", using: :btree
  add_index "user_organizations", ["user_id"], name: "index_user_organizations_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
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
    t.boolean  "send_freshsheet",        default: true, null: false
    t.boolean  "send_newsletter",        default: true, null: false
    t.integer  "legacy_id"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["send_freshsheet"], name: "index_users_on_send_freshsheet", using: :btree
  add_index "users", ["send_newsletter"], name: "index_users_on_send_newsletter", using: :btree

end
