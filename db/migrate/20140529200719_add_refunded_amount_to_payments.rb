class AddRefundedAmountToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :refunded_amount, :decimal, precision: 10, scale: 2, default: 0.0,     null: false
  end
end
