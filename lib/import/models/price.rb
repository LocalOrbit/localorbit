require 'import/models/base'
class Import::Price < Import::Base
  self.table_name = "product_prices"
  self.primary_key = "price_id"

  belongs_to :product, class_name: "Import::Product", foreign_key: "prod_id"

  def import
    ::Price.create(
      min_quantity: min_qty,
      sale_price: price
    )
  end
end
