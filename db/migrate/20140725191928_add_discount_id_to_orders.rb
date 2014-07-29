class AddDiscountIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :discount_id, :integer
  end
end
