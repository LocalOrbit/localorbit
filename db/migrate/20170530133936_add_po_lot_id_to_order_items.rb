class AddPoLotIdToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :po_lot_id, :integer
  end
end
