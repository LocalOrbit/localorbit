require "import/models/base"

module Imported
  class Price < ActiveRecord::Base
    self.table_name = "prices"

    belongs_to :product, class_name: "Imported::Product", inverse_of: :prices
  end
end

class Legacy::Price < Legacy::Base
  self.table_name = "product_prices"
  self.primary_key = "price_id"

  belongs_to :product, class_name: "Legacy::Product", foreign_key: "prod_id"

  def import
    imported = Imported::Price.where(legacy_id: price_id).first
    if imported.nil?
      imported = Imported::Price.new(
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
