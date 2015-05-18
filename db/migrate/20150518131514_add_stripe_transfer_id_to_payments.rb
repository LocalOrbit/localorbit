class AddStripeTransferIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :stripe_transfer_id, :string
  end
end
