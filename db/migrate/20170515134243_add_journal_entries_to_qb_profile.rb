class AddJournalEntriesToQbProfile < ActiveRecord::Migration
  def change
    add_column :qb_profiles, :ar_account_name, :string
    add_column :qb_profiles, :ar_account_id, :integer
    add_column :qb_profiles, :ap_account_name, :string
    add_column :qb_profiles, :ap_account_id, :integer
    add_column :qb_profiles, :fee_income_account_name, :string
    add_column :qb_profiles, :fee_income_account_id, :integer
    add_column :qb_profiles, :delivery_fee_account_name, :string
    add_column :qb_profiles, :delivery_fee_account_id, :integer
  end
end
