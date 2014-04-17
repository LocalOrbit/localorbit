class AddNameAndNotesToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :name, :string
    add_column :bank_accounts, :notes, :string
  end
end
