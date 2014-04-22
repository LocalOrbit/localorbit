require 'import/models/base'
class Import::Product < Import::Base
  self.table_name = "products"
  self.primary_key = "prod_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :unit, class_name: "Import::Unit"

  def import
    product = ::Product.new(
      name: name,
      who_story: who,
      how_story: how,
      long_description: description,
      short_description: short_description,
      deleted_at: is_deleted ? DateTime.current : nil
    )
    product
  end
end
