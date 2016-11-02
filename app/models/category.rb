class Category < ActiveRecord::Base
  audited allow_mass_assignment: true
  acts_as_nested_set order: :name
  has_many :products
  has_many :category_fees

  validates :name, presence: true

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

      if depth == 1
        names[2..2] = nil
      end

      if depth < 3
        hash[names[1]] << [names[2..2].join(" / "), category.id]
      end
    end
    hash
  end

  def self.for_fee_select
    array = Array.new
    each_with_level(root.descendants) do |category, depth|
      if depth < 3
        array << [category.parent.name + ' / ' + category.name, category.id]
      end
    end
    array
  end

  def get_level
    ret_val = ''
    ret_val = 'top' if top?
    ret_val = 'second' if second?
    ret_val = 'product' if ret_val.blank?
    ret_val
  end

  def top?
    depth == 1
  end

  def second?
    depth == 2
  end

  def top_level_category
    @top_level_category ||= self_and_ancestors.find_by(depth: 1)
  end

  def level_fee(market_id, category=nil)
    if !market_id.nil?
      if category.nil?
        cat = self
      else
        cat = category
      end

      if !cat.category_fees.where(market_id: market_id).first.nil? && cat.depth > 0
        cat.category_fees.first.fee_pct
      elsif !cat.parent.nil?
        level_fee(market_id, cat.parent)
      else
        0
      end
    else
      0
    end
  end
end
