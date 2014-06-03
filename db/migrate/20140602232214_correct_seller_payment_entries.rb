class CorrectSellerPaymentEntries < ActiveRecord::Migration
  class Payment < ActiveRecord::Base
    has_many :order_payments, inverse_of: :payment
    has_many :orders, through: :order_payments, inverse_of: :payments
  end

  class OrderPayment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment
  end

  class Order < ActiveRecord::Base
    has_many :order_payments, inverse_of: :order
    has_many :payments, through: :order_payments, inverse_of: :orders
  end

  def change
    updated = Payment.where(payment_type: ["cash", "check"]).each do |payment|
      payment.payment_method = payment.payment_type
      payment.payment_type   = "seller payment"
      payment.save
    end.size

    puts "Corrected payment_method on #{updated} payments records"

    updated = Payment.where(payment_type: "seller payment").includes(:orders).each do |payment|
      payment.payer_type = "Market"
      payment.payer_id   = payment.orders.first.market_id
      payment.save
    end.size

    puts "Corrected payer on #{updated} seller payment records"
  end
end
