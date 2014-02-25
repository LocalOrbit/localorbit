class Product < ActiveRecord::Base
  belongs_to :category
  belongs_to :organization
  belongs_to :location

  has_many :lots, lambda { order('created_at') }, autosave: true

  validates :name, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true

  validate :ensure_organization_can_sell

  delegate :name, to: :organization, prefix: true

  scope_accessible :organization, method: :for_organization_id, ignore_blank: true

  def self.available_for_market(market)
    return none unless market

    where(organization: market.organization_ids)
  end

  def self.for_organization_id(organization_id)
    where(organization_id: organization_id)
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

  private

  def ensure_organization_can_sell
    unless organization.present? && organization.can_sell?
      errors.add(:organization, "must be able to sell products")
    end
  end
end
