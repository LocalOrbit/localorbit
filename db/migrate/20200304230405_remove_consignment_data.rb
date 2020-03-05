class RemoveConsignmentData < ActiveRecord::Migration
  def up
    Order.where(order_type: 'purchase').destroy_all
    Organization.where(payment_model: 'consignment').destroy_all
  end
end
