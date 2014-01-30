class AddIndexForParentIdOnCategories < ActiveRecord::Migration
  def change
    add_index :categories, :parent_id
  end
end
