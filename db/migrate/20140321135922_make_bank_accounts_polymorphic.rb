class MakeBankAccountsPolymorphic < ActiveRecord::Migration
  def up
    rename_column :bank_accounts, :organization_id, :bankable_id
    add_column :bank_accounts, :bankable_type, :string

    BankAccount.where("bankable_id IS NOT NULL").update_all(bankable_type: "Organization")

    remove_index :bank_accounts, :bankable_id
    add_index :bank_accounts, [:bankable_type, :bankable_id]
  end

  def down
    rename_column :bank_accounts, :bankable_id, :organization_id
    remove_column :bank_accounts, :bankable_type

    add_index :bank_accounts, :bankable_id
    remove_index :bank_accounts, [:bankable_type, :bankable_id]
  end
end
