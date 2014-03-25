class ConvertCategoriesToNestedSet < ActiveRecord::Migration
  class Category < ActiveRecord::Base
    acts_as_nested_set order: name
  end

  def change
    change_table :categories do |t|
      t.integer :lft
      t.integer :rgt
      t.integer :depth
    end
    add_index :categories, :lft
    add_index :categories, :rgt
    add_index :categories, [:parent_id, :lft]
    add_index :categories, [:parent_id, :lft, :rgt]

    Category.rebuild!
    new_root = Category.find_or_create_by!(name: "All", parent_id: nil)
    Category.roots.each do |old_root|
      old_root.move_to_child_of(new_root) unless old_root == new_root
    end
  end
end
