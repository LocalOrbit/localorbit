class AddSecondLevelCategoryIdToProducts < ActiveRecord::Migration
  class Category < ActiveRecord::Base
    acts_as_nested_set order: :name
  end

  class Product < ActiveRecord::Base
    belongs_to :category
  end

  def up
    add_column :products, :second_level_category_id, :integer

    Product.group(:category_id).pluck(:category_id).each do |cat_id|
      sec_id = Category.find(cat_id).self_and_ancestors.find_by(depth: 2).id
      Product.where(category_id: cat_id).update_all(second_level_category_id: sec_id)
    end
  end

  def down
    remove_column :products, :second_level_category_id
  end
end
