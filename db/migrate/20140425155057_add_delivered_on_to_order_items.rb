class AddDeliveredOnToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :delivered_at, :datetime
  end
end
