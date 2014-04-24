require 'import/models/base'

class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :location
  belongs_to :unit
  belongs_to :organization, inverse_of: :products

  has_many :lots, -> { order("created_at") }, inverse_of: :product, autosave: true
  has_many :prices, autosave: true, inverse_of: :product
end

class Import::Product < Import::Base
  self.table_name = "products"
  self.primary_key = "prod_id"

  has_many :lots, class_name: "Import::Lot", foreign_key: "prod_id"
  has_many :prices, class_name: "Import::Price", foreign_key: "prod_id"

  belongs_to :organization, class_name: "Import::Organization", foreign_key: :org_id
  belongs_to :unit, class_name: "Import::Unit", foreign_key: :unit_id

  def import(organization)
    product = ::Product.new(
      name: name,
      unit: imported_unit,
      category: imported_category,
      location: imported_location(organization),
      who_story: who,
      how_story: how,
      long_description: imported_long_description,
      short_description: imported_short_description,
      deleted_at: is_deleted == 1 ? DateTime.current : nil,
      legacy_id: prod_id
    )

    lots.each {|lot| product.lots << lot.import }
    product.use_simple_inventory = (lots.count == 1)

    prices.each {|price| product.prices << price.import }

    product
  end

  def imported_unit
    imported = ::Unit.where(singular: unit.NAME).first if unit
    imported = ::Unit.where(singular: 'Each').first if (!defined?(import) || imported.nil?)
    imported
  end

  def imported_category
    ids = category_ids.split(',').reverse
    categories = ids.map do |id|
      begin
        Import::Category.find(id)
      rescue
      end
    end.compact

    new_category = ::Category.where(name: categories.first.cat_name)
    if new_category.count > 1
      old_category = categories.map do |category|
        category.cat_name
      end.join('/')

      new_category.each do |category|
        str = category_string(category.id)
        puts "#{old_category} == #{str}"
        if old_category = str
          return category
        end
      end
    else
      new_category.first
    end
  end

  def category_string(category_id)
    return if category_id.nil? || category_id == 1
    category = ::Category.find(category_id)

    result = []
    result << category.name
    result << category_string(category.parent_id)
    result.flatten.compact
  end

  def imported_location(organization)
    if who || how
      addr_id.nil? || addr_id == 0 ? organization.locations.first : ::Location.where(legacy_id: addr_id).first
    else
      nil
    end
  end

  def imported_short_description
    if short_description.blank?
      "[imported as blank]"
    else
      short_description[0...50]
    end
  end

  def imported_long_description
    description[0...500] if description
  end
end
