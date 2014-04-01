class AddUnitToProductsWithoutOne < ActiveRecord::Migration
  class Unit < ActiveRecord::Base
  end

  class Product < ActiveRecord::Base
  end

  def up
    unit = Unit.where(plural: "Each").first

    if unit
      Product.where(unit_id: nil).each do |product|
        product.update(unit_id: unit.id)
      end
    end
  end

  def down
  end
end
