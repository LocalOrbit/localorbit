class AddQuantityDeliveredToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :quantity_delivered, :integer
  end
end
