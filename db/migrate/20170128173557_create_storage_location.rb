class CreateStorageLocation < ActiveRecord::Migration
  def change
    create_table :storage_locations do |t|
      t.integer :market_id
      t.string :name
    end
  end
end
