class AdditionsForDeliveryNotes < ActiveRecord::Migration
  def change

  	add_column :delivery_notes, :note, :text

  	add_index :delivery_notes, [:cart_id, :supplier_org], unique: true

  end
end
