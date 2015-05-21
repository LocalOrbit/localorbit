class AddStripeRefundIdToPayments < ActiveRecord::Migration
  def change
    change_table :payments do |t|
      t.string :stripe_refund_id
    end
  end
end
