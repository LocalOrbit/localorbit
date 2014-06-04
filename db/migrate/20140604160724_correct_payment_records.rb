class CorrectPaymentRecords < ActiveRecord::Migration
  class Payment < ActiveRecord::Base
    has_many :order_payments
    has_many :orders, through: :order_payments
  end

  class OrderPayment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment
  end

  class Order < ActiveRecord::Base
  end

  def up
    count = 0

    Payment.where(payment_type: "order", payer_type: "User").find_each do |payment|
      order = payment.orders.first
      payment.payer_id = order.organization_id
      payment.payer_type = "Organization"
      payment.save!
      count += 1
    end

    puts "Corrected payer on #{count} payments records"
  end
end
