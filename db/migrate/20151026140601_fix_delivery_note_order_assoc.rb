class FixDeliveryNoteOrderAssoc < ActiveRecord::Migration
  def change
  	add_column :delivery_notes, :order_id, :integer
  end
end
