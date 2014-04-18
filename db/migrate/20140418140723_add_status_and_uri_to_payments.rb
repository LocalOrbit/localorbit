class AddStatusAndUriToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :status, :string
    add_column :payments, :balanced_uri, :string
  end
end
