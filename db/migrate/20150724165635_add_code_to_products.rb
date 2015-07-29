class AddCodeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :code, :string
    add_index :products, :code
  end
end
