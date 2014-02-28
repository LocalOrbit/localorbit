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

ActiveRecord::Schema.define(version: 20140228213942) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

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
    t.boolean  "active",        default: false, null: false
    t.string   "contact_name"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "facebook"
    t.string   "twitter"
    t.text     "profile"
    t.text     "policies"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "markets", ["subdomain"], name: "index_markets_on_subdomain", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.boolean  "can_sell"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "who_story"
    t.text     "how_story"
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
    t.boolean  "use_simple_inventory", default: true, null: false
    t.integer  "unit_id"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["location_id"], name: "index_products_on_location_id", using: :btree
  add_index "products", ["organization_id"], name: "index_products_on_organization_id", using: :btree

  create_table "units", force: true do |t|
    t.string   "singular"
    t.string   "plural"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
