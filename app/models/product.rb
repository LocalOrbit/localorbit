class Product < ActiveRecord::Base
  include SoftDelete
  include PgSearch
  include Sortable

  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :organization, inverse_of: :products
  belongs_to :location
  belongs_to :unit

  has_many :lots, -> { order("created_at") }, inverse_of: :product, autosave: true, dependent: :destroy
  has_many :lots_by_expiration, -> { order("expires_at, good_from, created_at") }, class_name: Lot, foreign_key: :product_id

  has_many :product_deliveries, dependent: :destroy
  has_many :delivery_schedules, through: :product_deliveries
  has_many :prices, autosave: true, inverse_of: :product, dependent: :destroy
  has_many :promotions, inverse_of: :product

  dragonfly_accessor :image

  validates :name, presence: true
  validates :unit, presence: true
  validates :category_id, presence: true
  validates :organization_id, presence: true
  validates :short_description, presence: true, length: {maximum: 50}
  validates :long_description, length: {maximum: 500}

  validates :location, presence: true, if: :overrides_organization?

  validate :ensure_organization_can_sell

  delegate :name, to: :organization, prefix: true

  scope_accessible :market, method: :for_market_id, ignore_blank: true
  scope_accessible :organization, method: :for_organization_id, ignore_blank: true
  scope_accessible :category, method: :for_category_id, ignore_blank: true
  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  pg_search_scope :search_by_name, against: :name, using: { tsearch: { prefix: true }}

  before_save :update_top_level_category
  before_save :update_delivery_schedules

  def self.available_for_market(market)
    return none unless market

    visible.seller_can_sell.where(organization: market.organization_ids)
  end

  # Does not explicitly scope to the market. Use in conjunction with available_for_market.
  def self.available_for_sale(market, buyer=nil, deliver_on_date=Time.current)
    visible.seller_can_sell.
      with_available_inventory(deliver_on_date).
      priced_for_market_and_buyer(market, buyer).

      group("products.id")
  end

  def self.priced_for_market_and_buyer(market, buyer=nil)
    price_table = Price.arel_table
    on_cond = arel_table[:id].eq(price_table[:product_id]).
              and(price_table[:market_id].eq(market.id).or(price_table[:market_id].eq(nil)))

    if buyer
      on_cond = on_cond.and(price_table[:organization_id].eq(buyer.id).or(price_table[:organization_id].eq(nil)))
    else
      on_cond = on_cond.and(price_table[:organization_id].eq(nil))
    end
    price_join = arel_table.create_join(price_table, arel_table.create_on(on_cond))

    joins(price_join)
  end

  def self.seller_can_sell
    joins(:organization).where(organizations: {can_sell: true, active: true})
  end

  def self.for_market_id(market_id)
    joins(organization: :market_organizations).where(market_organizations: {market_id: market_id})
  end

  def self.for_organization_id(organization_id)
    where(organization_id: organization_id)
  end

  def self.for_category_id(category_id)
    where(top_level_category_id: category_id)
  end

  def self.for_sort(order)
    column, direction = column_and_direction(order)
    case column
    when "price"
      joins("left outer join prices on products.id = prices.product_id").
        select("products.*, coalesce(MAX(prices.sale_price), 0) as price").
        group("products.id").order_by_price(direction)
    when "stock"
      lot = Lot.arel_table
      expires_condition = lot[:expires_at].gt(Time.current).or(lot[:expires_at].eq(nil))
      good_from = lot[:good_from].lt(Time.current).or(lot[:good_from].eq(nil))
      joins("LEFT OUTER JOIN lots ON products.id = lots.product_id AND #{expires_condition.and(good_from).to_sql}").
        select("products.*, SUM(lots.quantity) as stock").
        group("products.id").order_by_stock(direction)
    when "seller"
      order_by_seller_name(direction)
    when "market"
      joins(organization: { market_organizations: :market}).order_by_market_name(direction)
    else
      order_by_name(direction)
    end
  end

  def self.for_search(query)
    search_by_name(query)
  end

  def self.with_available_inventory(deliver_on_date=Time.current)
    lot_table = Lot.arel_table
    on_cond = arel_table[:id].eq(lot_table[:product_id]).
              and(lot_table[:good_from].eq(nil).or(lot_table[:good_from].lt(deliver_on_date))).
              and(lot_table[:expires_at].eq(nil).or(lot_table[:expires_at].gt(deliver_on_date))).
              and(lot_table[:quantity].gt(0))
    join_on = arel_table.create_on(on_cond)

    joins(arel_table.create_join(Lot.arel_table, join_on))
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
    if lots.loaded?
      lots.to_a.sum {|l| l.available?(deliver_on_date) ? l.quantity : 0 }
    else
      lots.available(deliver_on_date).sum(:quantity)
    end
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
    organization.try(:name)
  end

  def unit_plural
    unit_with_description(:plural)
  end

  def unit_singular
    unit_with_description(:singular)
  end

  def unit_with_description(singular_or_plural)
    if unit_description.present?
      "#{unit.try(singular_or_plural)}, #{unit_description}"
    else
      unit.try(singular_or_plural)
    end
  end

  def prices_for_market_and_organization(market, organization)
    if prices.loaded?
      prices.inject({}) do |final_prices, price|
        if price.for_market_and_organization?(market, organization) && (price.organization_id || !final_prices.key?(price.min_quantity))
          final_prices[price.min_quantity] = price
        end

        final_prices
      end.values.sort {|a,b| a.min_quantity <=> b.min_quantity }
    else
      prices.where(market_id: [market.id, nil], organization_id: [organization.id, nil]).
        order("min_quantity, organization_id desc nulls first").
        index_by {|price| price.min_quantity }.values
    end
  end

  private

  def self.order_by_name(direction)
    direction == "asc" ? order(name: :asc) : order(name: :desc)
  end

  def self.order_by_market_name(direction)
    direction == "asc" ? order("markets.name asc") : order("markets.name desc")
  end

  def self.order_by_seller_name(direction)
    direction == "asc" ? order("organizations.name asc") : order("organizations.name desc")
  end

  def self.order_by_stock(direction)
    direction == "asc" ? order("stock asc nulls first, name asc") : order("stock desc nulls last, name desc")
  end

  def self.order_by_price(direction)
    direction == "asc" ? order("price asc") : order("price desc")
  end

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
    if use_all_deliveries?
      self.delivery_schedule_ids = organization.reload.all_markets.map do |market|
        market.delivery_schedules.visible.map(&:id)
      end.flatten
    else
      ids = organization.reload.all_markets.map(&:id)
      self.delivery_schedules = self.delivery_schedules.select {|ds| ids.include?(ds.market.id) }
    end
  end
end
