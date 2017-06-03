class AddCtIdToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :po_ct_id, :integer
  end
end
