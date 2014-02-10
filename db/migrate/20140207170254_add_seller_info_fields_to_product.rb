class AddSellerInfoFieldsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :who_story, :text
    add_column :products, :how_story, :text
  end
end
