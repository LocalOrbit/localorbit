class AddMonthAndYearExpirationToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :expiration_month, :integer
    add_column :bank_accounts, :expiration_year, :integer
  end
end
