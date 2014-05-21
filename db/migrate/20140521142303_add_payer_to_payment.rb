class AddPayerToPayment < ActiveRecord::Migration
  def up
    add_column :payments, :payer_id, :integer
    add_column :payments, :payer_type, :string

    Payment.all.each do |payment|
      payment.payer = payment.orders.first.organization
      payment.save!
    end
  end

  def down
    remove_column :payments, :payer_id
    remove_column :payments, :payer_type
  end
end
