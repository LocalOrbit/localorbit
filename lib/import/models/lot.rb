require "import/models/base"

module Imported
  class Lot < ActiveRecord::Base
    self.table_name = "lots"

    belongs_to :product, class_name: "Imported::Product", inverse_of: :lots
  end
end

class Legacy::Lot < Legacy::Base
  self.table_name = "product_inventory"
  self.primary_key = "inv_id"

  belongs_to :product, class_name: "Legacy::Product", foreign_key: "prod_id"

  def import
    imported = Imported::Lot.where(legacy_id: inv_id).first

    if imported.nil?
      imported = Imported::Lot.new(
        number: lot_id,
        good_from: good_from,
        expires_at: expires_on,
        quantity: qty,
        legacy_id: inv_id
      )
    end

    imported
  end
end
