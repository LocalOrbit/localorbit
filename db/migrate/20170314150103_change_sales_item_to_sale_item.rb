class ChangeSalesItemToSaleItem < ActiveRecord::Migration
  def up
    rename_column :cart_items, :sales_price, :sale_price
  end
end