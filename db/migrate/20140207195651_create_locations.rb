class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name,             null: false
      t.string :address,          null: false
      t.string :city,             null: false
      t.string :state,            null: false
      t.string :zip,              null: false
      t.integer :organization_id, null: false

      t.timestamps
    end
    add_index :locations, :organization_id
  end
end
