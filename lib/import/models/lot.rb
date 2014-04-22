require 'import/models/base'
class Import::Lot < Import::Base
  self.table_name = "product_inventory"
  self.primary_key = "inv_id"

  belongs_to :product, class_name: "Import::Product", foreign_key: "prod_id"

  def import
    ::Lot.create(
      number: lot_id,
      good_from: good_from,
      expires_at: expires_on,
      quantity: qty
    )
  end
end
