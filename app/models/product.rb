class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :organization
  belongs_to :location
  belongs_to :unit

  has_many :lots, lambda { order('created_at') }, autosave: true
  has_many :prices, autosave: true, inverse_of: :product

  dragonfly_accessor :image

  validates :name, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true

  validates :location, presence: true, if: :overrides_organization?

  validate :ensure_organization_can_sell

  delegate :name, to: :organization, prefix: true

  scope_accessible :organization, method: :for_organization_id, ignore_blank: true
  scope_accessible :category, method: :for_category_id, ignore_blank: true

  before_save :update_top_level_category

  def self.available_for_market(market)
    return none unless market

    where(organization: market.organization_ids)
  end

  def self.for_organization_id(organization_id)
    where(organization_id: organization_id)
  end

  def self.for_category_id(category_id)
    where(top_level_category_id: category_id)
  end

  def can_use_simple_inventory?
    use_simple_inventory? || !lots.where('(expires_at IS NULL OR expires_at > ?) AND quantity > 0', Time.current).exists?
  end

  def simple_inventory
    lots.last.try(:available_quantity) || 0
  end

  def simple_inventory=(val)
    return val unless use_simple_inventory?

    lot = lots.to_a.last
    lot = lots.build unless lot.try(:simple?)
    lot.quantity = val
  end

  def available_inventory
    lots.available.sum(:quantity)
  end

  def unit_plural
    unit.try(:plural)
  end

  def unit_singular
    unit.try(:singular)
  end

  private

  def ensure_organization_can_sell
    unless organization.present? && organization.can_sell?
      errors.add(:organization, "must be able to sell products")
    end
  end

  def update_top_level_category
    if category_id_changed?
      top_level_category = category.top_level_category
    end
  end

  def overrides_organization?
    who_story.present? || how_story.present?
  end
end
