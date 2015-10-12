class AddDeliveryNotes < ActiveRecord::Migration
  def change
  	create_table :delivery_notes do |t|
  		t.timestamp :updated_at
  		t.timestamp :created_at
  		t.timestamp :deleted_at
  		t.integer :supplier_org
  		t.integer :buyer_org
  		t.integer :cart_id
  	end

  	add_index :delivery_notes, :cart_id

  end
end
