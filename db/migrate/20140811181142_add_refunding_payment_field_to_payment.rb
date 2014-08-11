class AddRefundingPaymentFieldToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :parent_id, :integer
  end
end
