class AddStripeEntityReferences < ActiveRecord::Migration
  def change
    change_table :bank_accounts do |t|
      t.string :stripe_id
    end

    change_table :markets do |t|
      t.string :stripe_customer_id
      t.string :stripe_account_id
    end

    change_table :organizations do |t|
      t.string :stripe_customer_id
    end

    change_table :payments do |t|
      t.string :stripe_id
    end
  end
end
