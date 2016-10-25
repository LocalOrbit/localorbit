class CreateCrossSellingLists < ActiveRecord::Migration
  def change
    create_table :cross_selling_lists do |t|
		t.string :name, :limit=>255, null: false
		t.integer :entity_id, polymorphic: true, null: false
		t.string :entity_type, :limit=>255, null: false
		t.references :parent, references: :cross_selling_lists, index: true, null: true
		t.boolean :creator, default: false
		t.string :status, :limit=>255, null: false, default: 'Draft'
		t.timestamp :published_at
		t.timestamp :deleted_at
		t.timestamps
    end
  end
end
