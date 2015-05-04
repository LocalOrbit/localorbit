class AddStripePaymentFeeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :stripe_payment_fee, :decimal, precision: 10, scale: 2, default: 0.0, null: false
  end
end
