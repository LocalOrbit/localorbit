class AddGcToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent_product_id, :integer
    add_column :products, :unit_quantity, :integer
    add_column :products, :organic, :boolean
  end
end
