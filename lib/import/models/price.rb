require 'import/models/base'
class Price < ActiveRecord::Base
  belongs_to :product, inverse_of: :prices
end

class Import::Price < Import::Base
  self.table_name = "product_prices"
  self.primary_key = "price_id"

  belongs_to :product, class_name: "Import::Product", foreign_key: "prod_id"

  def import
    imported = ::Price.where(legacy_id: price_id).first
    if imported.nil?
      imported = ::Price.new(
        min_quantity: imported_quantity,
        sale_price: imported_price,
        legacy_id: price_id
      )
    end

    imported
  end

  def imported_quantity
    min_qty.nil? || min_qty == 0 ? 1 : min_qty
  end

  def imported_price
    price == 0 ? 1.00 : price
  end
end
