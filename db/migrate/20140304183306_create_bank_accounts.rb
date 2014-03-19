class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :bank_name
      t.string :last_four
      t.string :account_type
      t.string :balanced_uri
      t.integer :organization_id
      t.timestamps
    end

    add_index :bank_accounts, :organization_id
  end
end
