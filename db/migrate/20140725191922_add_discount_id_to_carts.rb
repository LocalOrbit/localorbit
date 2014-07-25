class AddDiscountIdToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :discount_id, :integer
  end
end
