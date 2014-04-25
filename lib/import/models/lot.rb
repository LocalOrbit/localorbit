require 'import/models/base'
class Lot < ActiveRecord::Base
  belongs_to :product, inverse_of: :lots
end

class Import::Lot < Import::Base
  self.table_name = "product_inventory"
  self.primary_key = "inv_id"

  belongs_to :product, class_name: "Import::Product", foreign_key: "prod_id"

  def import
    imported = ::Lot.where(legacy_id: inv_id).first

    if imported.nil?
      imported = ::Lot.new(
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
