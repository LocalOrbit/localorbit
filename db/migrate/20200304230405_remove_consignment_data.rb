class RemoveConsignmentData < ActiveRecord::Migration
  def up
    Order.auditing_enabled = false
    OrderItem.auditing_enabled = false
    OrderItemLot.auditing_enabled = false

    Order.where(order_type: 'purchase').destroy_all
    Organization.where(payment_model: 'consignment').destroy_all
  end
end
