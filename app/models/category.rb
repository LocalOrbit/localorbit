class Category < ActiveRecord::Base
  audited allow_mass_assignment: true
  acts_as_nested_set order: :name
  has_many :products

  scope :for_products, lambda {|products| joins(:products).where(products: {id: products}).uniq }

  # Returns select list options with root Categories as option groups
  #
  # {"Beverages" => [
  #    ["Coffee, Tea, & Cocoa / Coffee", 2518],
  #    ["Beer, Wine, & Spirits / Beer / Ale", 2521],
  #    ["Beer, Wine, & Spirits / Wine / Red Wine", 2523],
  #  ]}
  def self.for_select
    hash = Hash.new {|h, k| h[k] = [] } # default keys to []
    names = []
    each_with_level(root.descendants) do |category, depth|
      names[depth] = category.name

      if category.leaf?
        hash[names[1]] << [names[2..depth].join(" / "), category.id]
      end
    end
    hash
  end

  def top_level_category
    @top_level_category ||= self_and_ancestors.find_by(depth: 1)
  end
end
