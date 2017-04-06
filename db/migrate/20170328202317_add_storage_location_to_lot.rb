class AddStorageLocationToLot < ActiveRecord::Migration
  def change
    add_column :lots, :storage_location_id, :integer
  end
end
