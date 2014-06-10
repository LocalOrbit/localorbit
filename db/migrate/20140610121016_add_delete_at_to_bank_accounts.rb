class AddDeleteAtToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :deleted_at, :datetime
  end
end
