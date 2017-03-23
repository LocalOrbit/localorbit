class AddHoldoverOrderToConsignmentTransaction < ActiveRecord::Migration
  def change
    add_column :consignment_transactions, :holdover_order_id, :integer
  end
end
