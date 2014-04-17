class AddPaymentUriToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :payment_uri, :string
    add_column :payments, :status, :string
  end
end
