class UpdateBuyerPaymentPayers < ActiveRecord::Migration
  class Order < ActiveRecord::Base; end
  class OrderPayment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment
  end
  class Payment < ActiveRecord::Base
    has_many :order_payments
    has_many :orders, through: :order_payments
  end

  def up
    total = Payment.where(payment_type: "order", payer_id: nil).count
    puts "#{total} payments need to be updated"
    Payment.where(payment_type: "order", payer_id: nil).find_each.with_index do |payment, idx|
      puts "(#{idx+1}/#{total}) Updating payment #{payment.id}"
      begin
        payment.payer_type = "Organization"
        payment.payer_id   = payment.orders.first.organization_id
        payment.save!
      rescue => e
        puts "Trouble with payment #{payment.id}: #{e.inspect}"
      end
    end
  end

  def down
    # Nothing to do here
  end
end
