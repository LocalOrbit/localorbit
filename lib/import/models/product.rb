require 'import/models/base'
class Import::Product < Import::Base
  self.table_name = "products"
  self.primary_key = "prod_id"

  has_many :lots, class_name: "Import::Lot", foreign_key: "prod_id"
  has_many :prices, class_name: "Import::Price", foreign_key: "prod_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :unit, class_name: "Import::Unit", foreign_key: :unit_id

  def import
    imported_unit = ::Unit.where(singular: unit.NAME).first

    product = ::Product.new(
      name: name,
      unit: imported_unit,
      who_story: who,
      how_story: how,
      long_description: description,
      short_description: short_description,
      deleted_at: is_deleted ? DateTime.current : nil
    )

    lots.each {|lot| product.lots << lot.import }
    prices.each {|price| product.prices << price.import }

    product
  end
end
