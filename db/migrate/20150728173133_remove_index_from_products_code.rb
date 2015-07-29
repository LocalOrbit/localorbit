class RemoveIndexFromProductsCode < ActiveRecord::Migration
  def change
    remove_index :products, :column => [:code]
  end
end
