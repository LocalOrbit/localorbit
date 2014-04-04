class MoveDeliveryStatusToOrderItem < ActiveRecord::Migration
  class OrderItem < ActiveRecord::Base; end

  def up
    add_column :order_items, :delivery_status, :string
    remove_column :orders, :delivery_status

    OrderItem.update_all(delivery_status: 'pending')
  end

  def down
    add_column :orders, :delivery_status, :string
    remove_column :order_items, :delivery_status
  end
end
