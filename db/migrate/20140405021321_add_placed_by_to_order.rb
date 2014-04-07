class AddPlacedByToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :placed_by_id, :integer
  end
end
