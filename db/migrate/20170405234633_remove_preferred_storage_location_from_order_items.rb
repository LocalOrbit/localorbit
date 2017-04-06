class RemovePreferredStorageLocationFromOrderItems < ActiveRecord::Migration
  def change
    remove_column :order_items, :preferred_storage_location_id
  end
end
