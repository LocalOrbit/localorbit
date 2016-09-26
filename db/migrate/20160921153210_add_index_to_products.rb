class AddIndexToProducts < ActiveRecord::Migration
  def change
    add_index :products, :second_level_category_id
  end
end
