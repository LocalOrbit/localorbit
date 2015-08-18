class DropProductColumns < ActiveRecord::Migration
  def change
    remove_column :products, :name, :text
    remove_column :products, :who_story, :text
    remove_column :products, :how_story, :text
    remove_column :products, :image_uid, :string
    remove_column :products, :short_description, :text
    remove_column :products, :long_description, :text
    remove_column :products, :use_all_deliveries, :boolean, default: true
    remove_column :products, :thumb_uid, :string
  end
end