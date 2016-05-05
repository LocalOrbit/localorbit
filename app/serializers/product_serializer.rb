class ProductSerializer < ActiveModel::Serializer
	attributes :id, :name, :category_id, :organization_id, :created_at, :updated_at, :who_story, :how_story, :location_id, :use_simple_inventory, :unit_id, :image_uid, :top_level_category, :deleted_at, :short_description, :long_description, :use_all_deliveries, :unit_description, :thumb_uid, :second_level_category, :code, :general_product_id
end