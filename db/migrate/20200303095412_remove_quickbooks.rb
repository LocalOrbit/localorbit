class RemoveQuickbooks < ActiveRecord::Migration
  def change
    drop_table "qb_profiles" do |t|
      t.integer "organization_id"
      t.string  "income_account_name"
      t.integer "income_account_id"
      t.string  "expense_account_name"
      t.integer "expense_account_id"
      t.string  "asset_account_name"
      t.integer "asset_account_id"
      t.string  "prefix"
      t.string  "delivery_fee_item_name"
      t.integer "delivery_fee_item_id"
      t.string  "consolidated_supplier_item_name"
      t.integer "consolidated_supplier_item_id"
      t.string  "consolidated_buyer_item_name"
      t.integer "consolidated_buyer_item_id"
      t.string  "ar_account_name"
      t.integer "ar_account_id"
      t.string  "ap_account_name"
      t.integer "ap_account_id"
      t.string  "fee_income_account_name"
      t.integer "fee_income_account_id"
      t.string  "delivery_fee_account_name"
      t.integer "delivery_fee_account_id"
    end

    drop_table "qb_tokens" do |t|
      t.integer  "organization_id"
      t.string   "encrypted_access_token"
      t.string   "encrypted_access_secret"
      t.string   "encrypted_realm_id"
      t.datetime "token_expires_at"
      t.string   "encrypted_access_token_iv"
      t.string   "encrypted_access_secret_iv"
      t.string   "encrypted_realm_id_iv"
    end

    remove_column :markets, :qb_integration_type, :string
    remove_column :orders, :qb_ref_id, :integer
    remove_column :organizations, :qb_org_id, :integer
    remove_column :organizations, :qb_check_name, :string
    remove_column :products, :qb_item_id, :integer
  end
end
