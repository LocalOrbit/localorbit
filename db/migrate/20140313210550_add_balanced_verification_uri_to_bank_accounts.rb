class AddBalancedVerificationUriToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :balanced_verification_uri, :string
  end
end
