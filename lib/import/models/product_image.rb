require "import/models/base"
class Legacy::ProductImage < Legacy::Base
  self.table_name = "product_images"
  self.primary_key = "pimg_id"

  belongs_to :product, class_name: "Legacy::Product", foreign_key: :prod_id
end
