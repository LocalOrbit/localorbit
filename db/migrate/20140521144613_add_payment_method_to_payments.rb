class AddPaymentMethodToPayments < ActiveRecord::Migration
  def up
    add_column :payments, :payment_method, :string

    Payment.all.each do |payment|
      payment.payment_method = payment.payment_type
      payment.payment_type = nil
      payment.save!
    end
  end

  def down
    Payment.all.each do |payment|
      payment.payment_type = payment.payment_method
      payment.save!
    end

    remove_column :payments, :payment_method
  end
end
