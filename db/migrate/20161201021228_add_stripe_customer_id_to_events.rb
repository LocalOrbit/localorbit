class AddStripeCustomerIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :stripe_customer_id, :text
  end
end
