class AddIndexForDepthOnCategories < ActiveRecord::Migration
  def change
    add_index :categories, :depth
  end
end
