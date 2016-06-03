class AddCategoryFeeToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :category_fee_pct, :decimal, precision: 5, scale: 3
  end
end
