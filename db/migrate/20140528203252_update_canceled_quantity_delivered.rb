class UpdateCanceledQuantityDelivered < ActiveRecord::Migration
  class OrderItem < ActiveRecord::Base; end

  def up
    updates = OrderItem.where(delivery_status: 'canceled').update_all(quantity_delivered: 0)
    puts "Updated #{updates} OrderItem records"
  end

  def down
  end
end
