class CreateGeneralProducts < ActiveRecord::Migration
  def change
    create_table :general_products do |t|
      t.text :name
      t.integer :category_id
      t.integer :organization_id
      t.text :who_story
      t.text :how_story
      t.integer :location_id, index: true
      t.string :image_uid
      t.integer :top_level_category_id, index: true
      t.datetime :deleted_at
      t.text :short_description
      t.text :long_description
      t.boolean :use_all_deliveries, default: true
      t.string :thumb_uid
      t.integer :second_level_category_id
      t.timestamps
    end
  end
end
