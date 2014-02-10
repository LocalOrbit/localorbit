class AddLocationIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :location_id, :integer
    add_index  :products, :location_id
  end
end
