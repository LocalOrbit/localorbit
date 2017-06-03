class AddCtIdToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :ct_id, :integer
  end
end
