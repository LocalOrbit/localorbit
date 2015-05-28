class AddAccountRoleToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :account_role, :string
  end
end
