class GeneralProduct < ActiveRecord::Base
  extend DragonflyBackgroundResize
  include SoftDelete
  include PgSearch

  belongs_to :category
  belongs_to :top_level_category, class_name: Category
  belongs_to :second_level_category, class_name: Category
  belongs_to :organization, inverse_of: :general_products
  belongs_to :location

  has_many :product

  attr_accessor :skip_validation

  dragonfly_accessor :image do
    copy_to(:thumb){|a| a.thumb('150x150#') }
  end

  validates :name, presence: true, on: :create

  dragonfly_accessor :thumb
  define_after_upload_resize(:image, 1200, 1200, thumb: {width: 150, height: 150})
  validates_property :format, of: :image, in: %w(jpg jpeg png gif), :unless => :skip_validation
  validates_property :format, of: :thumb, in: %w(jpg jpeg png gif), :unless => :skip_validation

  pg_search_scope :search_by_text,
                  :against => :name,
                  :associated_against => {
                      :top_level_category => :name,
                      :second_level_category => :name,
                      :organization => :name
                  },
                  :using => {
                      :tsearch => {prefix: true}
                  }

  def self.filter_by_name_or_category_or_supplier(name)
    if name && name.length > 2
      #where("upper(general_products.name) LIKE ? OR upper(top_level_category.name) LIKE ? OR upper(second_level_category.name) LIKE ? OR upper(supplier.name) LIKE ?", "%#{name.upcase}%", "%#{name.upcase}%", "%#{name.upcase}%", "%#{name.upcase}%")
      search_by_text(name)
    else
       all
    end
  end

  def self.filter_by_categories(category_ids)
    if category_ids && category_ids.length > 0
      where("(general_products.category_id IN (?)
              OR general_products.top_level_category_id IN (?)
              OR general_products.second_level_category_id in (?))", category_ids, category_ids, category_ids)
    else
      all
    end
  end

  def self.filter_by_suppliers(supplier_ids)
    if supplier_ids && supplier_ids.length > 0
      where(organization: supplier_ids)
    else
      all
    end
  end

  def self.filter_by_active_org
    where("supplier.active = 'true' AND market_organizations.deleted_at IS NULL")
  end

  def self.filter_by_current_order(order)
    if order
      ids = order.items.map(&:product).map(&:id).flatten
      where("p_child.id NOT IN (?)", ids)
    else
      all
    end
  end

  def skip_validation?
  end
end
