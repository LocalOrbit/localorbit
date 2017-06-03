class AddCtIdToCart < ActiveRecord::Migration
  def change
    add_column :carts, :ct_id, :integer
  end
end
