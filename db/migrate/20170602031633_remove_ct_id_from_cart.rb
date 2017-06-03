class RemoveCtIdFromCart < ActiveRecord::Migration
  def change
    remove_column :carts, :ct_id
  end
end
