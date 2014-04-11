class Product < ActiveRecord::Base
  include SoftDelete

  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :organization
  belongs_to :location
  belongs_to :unit

  has_many :lots, -> { order("created_at") }, inverse_of: :product, autosave: true
  has_many :lots_by_expiration, -> { order("expires_at, good_from, created_at") }, class_name: Lot, foreign_key: :product_id

  has_many :product_deliveries
  has_many :delivery_schedules, through: :product_deliveries
  has_many :prices, autosave: true, inverse_of: :product

  dragonfly_accessor :image

  validates :name, presence: true
  validates :unit, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true
  validates :short_description, presence: true

  validates :location, presence: true, if: :overrides_organization?

  validate :ensure_organization_can_sell

  delegate :name, to: :organization, prefix: true

  scope_accessible :organization, method: :for_organization_id, ignore_blank: true
  scope_accessible :category, method: :for_category_id, ignore_blank: true

  before_save :update_top_level_category
  before_save :update_delivery_schedules, if: "use_all_deliveries?"

  def self.available_for_market(market)
    return none unless market

    visible.seller_can_sell.where(organization: market.organization_ids)
  end

  # Does not explicitly scope to the market. Use in conjunction with available_for_market.
  def self.available_for_sale(market, buyer=nil, deliver_on_date=Time.current)
    visible.seller_can_sell.
      joins(:lots, :prices).select("DISTINCT(products.*)").
      where("(lots.good_from IS NULL OR lots.good_from < :time) AND (lots.expires_at IS NULL OR lots.expires_at > :time) AND quantity > 0", time: deliver_on_date).
      where("prices.market_id = ? OR prices.market_id IS NULL", market.id).
      available_for_sale_price_conditions_for_buyer(buyer).
      having("SUM(lots.quantity) >= MIN(prices.min_quantity)").group("products.id")
  end

  def self.available_for_sale_price_conditions_for_buyer(buyer=nil)
    if buyer
      where("prices.organization_id = ? OR prices.organization_id IS NULL", buyer.id)
    else
      where("prices.organization_id IS NULL")
    end
  end

  def self.seller_can_sell
    joins(:organization).where(organizations: {can_sell: true})
  end

  def self.for_organization_id(organization_id)
    where(organization_id: organization_id)
  end

  def self.for_category_id(category_id)
    where(top_level_category_id: category_id)
  end

  def can_use_simple_inventory?
    use_simple_inventory? || !lots.where("(expires_at IS NULL OR expires_at > ?) AND quantity > 0", Time.current).exists?
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

  def available_inventory(deliver_on_date=DateTime.current)
    lots.available(deliver_on_date).sum(:quantity)
  end

  def minimum_quantity_for_purchase(opts={})
    prices.for_market_and_org(opts[:market], opts[:organization]).minimum("min_quantity")
  end

  def market_name
    organization.markets.first.name
  end

  def net_percent
    organization.markets.first.seller_net_percent
  end

  def organization_name
    organization.name
  end

  def unit_plural
    unit.try(:plural)
  end

  def unit_singular
    unit.try(:singular)
  end

  def prices_for_market_and_organization(market, organization)
    ids = [organization.id, nil]
    prices.where(market_id: [market.id, nil]).where(organization_id: ids).order("min_quantity, organization_id desc nulls first").index_by {|price| price.min_quantity }.values
  end

  private

  def ensure_organization_can_sell
    unless organization.present? && organization.can_sell?
      errors.add(:organization, "must be able to sell products")
    end
  end

  def update_top_level_category
    if category_id_changed?
      self.top_level_category = category.top_level_category
    end
  end

  def overrides_organization?
    who_story.present? || how_story.present?
  end

  def update_delivery_schedules
    self.delivery_schedule_ids = organization.markets.map do |market|
      market.delivery_schedules.visible.map(&:id)
    end.flatten
  end
end
