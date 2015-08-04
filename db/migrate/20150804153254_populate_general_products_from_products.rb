class PopulateGeneralProductsFromProducts < ActiveRecord::Migration
  
  def up
    execute "
      INSERT INTO general_products(
        id, 
        name, 
        who_story, 
        how_story, 
        location_id, 
        image_uid, 
        top_level_category_id, 
        short_description, 
        long_description, 
        use_all_deliveries, 
        thumb_uid,
        second_level_category_id,
        created_at,
        updated_at
      ) (
        SELECT
          p.id,
          p.name,
          p.who_story,
          p.how_story,
          p.location_id,
          p.image_uid,
          p.top_level_category_id,
          p.short_description,
          p.long_description,
          p.use_all_deliveries,
          p.thumb_uid,
          p.second_level_category_id,
          now(),
          now()
        FROM products AS p
      );"

    execute "UPDATE products SET general_product_id=id;"

    execute "SELECT setval('general_products_id_seq', (SELECT id FROM general_products ORDER BY id DESC LIMIT 1) + 1);"
  end

  def down
    execute "DELETE FROM general_products;"
    execute "SELECT setval('general_products_id_seq', 1);"
    execute "UPDATE products SET general_product_id = NULL;"
  end
end
