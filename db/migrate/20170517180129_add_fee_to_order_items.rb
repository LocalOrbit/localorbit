class AddFeeToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :fee, :integer
  end
end
