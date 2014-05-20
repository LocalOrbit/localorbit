class CorrectQuantityDeliveredOnExistingRecords < ActiveRecord::Migration
  def up
    OrderItem.find_each do |order_item|
      if order_item.delivery_status == 'delivered'
        order_item.quantity_delivered = order_item.quantity
        order_item.save!
      elsif order_item.delivery_status == 'pending'
        order_item.quantity_delivered = nil
        order_item.save!
      end
    end
  end

  def down
  end
end
