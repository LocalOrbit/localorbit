class AddPreferredLocationToOrderItems < ActiveRecord::Migration
  def change
    add_column :order_items, :preferred_storage_location_id, :integer
  end
end
