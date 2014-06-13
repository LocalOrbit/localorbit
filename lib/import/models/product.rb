require 'import/models/base'
module Imported
  class Product < ActiveRecord::Base
    self.table_name = "products"

    belongs_to :category, class: ::Category
    belongs_to :top_level_category, class: Category
    belongs_to :location, class_name: "Imported::Location"
    belongs_to :unit
    belongs_to :organization, class_name: "Imported::Organization", inverse_of: :products

    has_many :product_deliveries, dependent: :destroy
    has_many :delivery_schedules, through: :product_deliveries

    has_many :lots, -> { order("created_at") }, inverse_of: :product, autosave: true
    has_many :prices, autosave: true, inverse_of: :product

    def update_top_level_category
      self.top_level_category = category.top_level_category if category
    end

    def update_delivery_schedules
      self.delivery_schedule_ids = organization.markets.map do |market|
        market.delivery_schedules.visible.map(&:id)
      end.flatten
    end
  end
end

class Legacy::Product < Legacy::Base
  self.table_name = "products"
  self.primary_key = "prod_id"

  has_many :lots, class_name: "Legacy::Lot", foreign_key: :prod_id
  has_many :prices, class_name: "Legacy::Price", foreign_key: :prod_id
  has_many :images, class_name: "Legacy::ProductImage", foreign_key: :prod_id

  belongs_to :organization, class_name: "Legacy::Organization", foreign_key: :org_id
  belongs_to :unit, class_name: "Legacy::Unit", foreign_key: :unit_id

  def import(organization)
    product = Imported::Product.where(legacy_id: prod_id).first
    if product.nil?
      puts "  - Creating product: #{name}"
      product = Imported::Product.new(
        name: name.clean,
        unit: imported_unit,
        category: imported_category,
        location: imported_location(organization),
        who_story: who.try(:clean),
        how_story: how.try(:clean),
        long_description: imported_long_description.try(:clean),
        short_description: imported_short_description.try(:clean),
        deleted_at: is_deleted == 1 ? DateTime.current : nil,
        legacy_id: prod_id
      )

      product.image_uid = import_image
      product.update_top_level_category
    else
      puts "  - Existing product: #{product.name}"
    end

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
        Legacy::Category.find(id)
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
      addr_id.nil? || addr_id == 0 ? organization.locations.first : Imported::Location.where(legacy_id: addr_id).first
    else
      nil
    end
  end

  def imported_short_description
    short_description
  end

  def imported_long_description
    description[0...500] if description
  end

  def import_image
    if images.present?
      begin
        img = images.first
        image = Dragonfly.app.fetch_url("http://app.localorb.it/img/products/cache/#{img.pimg_id}.#{img.width}.#{img.height}.#{img.width}.#{img.height}.#{img.extension}")
        image.store
      rescue
      end
    end
  end
end
