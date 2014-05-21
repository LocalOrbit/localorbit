class AddPaymentMethodToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :payment_method, :string
    change_column :payments, :payment_type, :string, default: 'order'

    Payment.all.each do |payment|
      payment.payment_method = payment.payment_type
      payment.payment_type = 'order'
      payment.save!
    end
  end

  def down
    Payment.all.each do |payment|
      payment.payment_type = payment.payment_method
      payment.save!
    end

    remove_column :payments, :payment_method
    change_column :payments, :payment_type, :string, default: nil
  end
end
