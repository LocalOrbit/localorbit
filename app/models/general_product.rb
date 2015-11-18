class GeneralProduct < ActiveRecord::Base
  extend DragonflyBackgroundResize
  include SoftDelete
  include PgSearch

  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :second_level_category, class: Category
  belongs_to :organization, inverse_of: :general_products
  belongs_to :location

  has_many :product

  dragonfly_accessor :image
  dragonfly_accessor :thumb
  define_after_upload_resize(:image, 1200, 1200, thumb: {width: 150, height: 150})
  validates_property :format, of: :image, in: %w(jpg jpeg png gif)
  validates_property :format, of: :thumb, in: %w(jpg jpeg png gif)

  pg_search_scope :search_by_text,
                  :against => :name,
                  :associated_against => {
                      :second_level_category => :name,
                      :organization => :name
                  },
                  :using => {
                      :tsearch => {prefix: true}
                  }

  def self.filter_by_name(name)
    if name && name.length > 2
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
end
