require 'import/models/base'
class Import::ProductImage < Import::Base
  self.table_name = "product_images"
  self.primary_key = "pimg_id"

  belongs_to :product, class_name: "Import::Product", foreign_key: :prod_id
end
