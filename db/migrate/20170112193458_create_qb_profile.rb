class CreateQbProfile < ActiveRecord::Migration
  def change
    create_table :qb_profiles do |t|
      t.integer :organization_id
      t.string :income_account_name
      t.integer :income_account_id
      t.string :expense_account_name
      t.integer :expense_account_id
      t.string :asset_account_name
      t.integer :asset_account_id
      t.string :prefix
    end
  end
end
