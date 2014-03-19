class AddVerifiedToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :verified, :boolean, default: false, null: false
  end
end
