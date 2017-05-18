class AddFeeToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :fee, :integer
  end
end
