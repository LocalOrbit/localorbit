class AddMarketIdToPayments < ActiveRecord::Migration
  class Payment < ActiveRecord::Base
    has_many :order_payments
    has_many :orders, through: :order_payments
  end

  class OrderPayment < ActiveRecord::Base
    belongs_to :order
    belongs_to :payment
  end

  class Order < ActiveRecord::Base; end

  def up
    add_column :payments, :market_id, :integer

    Payment.reset_column_information

    count = 0
    Payment.includes(:orders).find_each do |payment|
      if payment.orders.any?
        payment.market_id = payment.orders.first.market_id
      elsif payment.payer_type == 'Market'
        payment.market_id = payment.payer_id
      elsif payment.payee_type == 'Market'
        payment.market_id = payment.payee_id
      else
        puts "Could not determine market for payment #{payment.id}"
      end
      payment.save
      count += 1
    end

    puts "Reviewed #{count} payment records"
    if Payment.count > count
      puts "!!! WARNING: #{Payment.count - count} payment records were created while this migration ran"
    end
  end

  def down
    remove_column :payments, :market_id
  end
end
