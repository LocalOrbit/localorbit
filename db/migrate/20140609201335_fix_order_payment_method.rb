class FixOrderPaymentMethod < ActiveRecord::Migration
  def up
    count = Order.where(payment_method: "purchaseorder").update_all(payment_method: "purchase order")

    puts "Corrected payment_method on #{count} order records"
  end
end
