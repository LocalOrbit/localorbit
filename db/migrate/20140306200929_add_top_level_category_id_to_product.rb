class AddTopLevelCategoryIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :top_level_category_id, :integer

    Product.reset_column_information
    Product.all.each do |p|
      p.top_level_category_id = p.category.top_level_category.id
      p.save
    end
  end
end
