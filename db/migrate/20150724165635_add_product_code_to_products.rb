class AddProductCodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :product_code, :string
    add_index :products, :product_code
  end
end
