class Product < ActiveRecord::Base
  extend DragonflyBackgroundResize
  include SoftDelete
  include PgSearch
  include Sortable

  before_save :update_cached_categories
  before_save :update_delivery_schedules
  after_save :update_general_product
  audited allow_mass_assignment: true, associated_with: :organization

  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :second_level_category, class: Category
  belongs_to :organization, inverse_of: :products
  belongs_to :location
  belongs_to :unit
  belongs_to :external_product, inverse_of: :product
  belongs_to :general_product

  has_many :lots, -> { order("created_at") }, inverse_of: :product, autosave: true, dependent: :destroy
  has_many :lots_by_expiration, -> { order("expires_at, good_from, created_at") }, class_name: Lot, foreign_key: :product_id

  has_many :product_deliveries, dependent: :destroy
  has_many :delivery_schedules, through: :product_deliveries
  has_many :order_items
  has_many :orders, through: :order_items
  has_many :prices, -> {visible},  autosave: true, inverse_of: :product, dependent: :destroy
  has_many :promotions, inverse_of: :product

  dragonfly_accessor :image
  dragonfly_accessor :thumb
  define_after_upload_resize(:image, 1200, 1200, thumb: {width: 150, height: 150})
  validates_property :format, of: :image, in: %w(jpeg png gif)
  validates_property :format, of: :thumb, in: %w(jpeg png gif)

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

  pg_search_scope :search_by_name, against: :name, using: {tsearch: {prefix: true}}

  pg_search_scope :search_by_text,
    :against => :name,
    :associated_against => {
      :second_level_category => :name,
      :organization => :name
    },
    :using => {
      :tsearch => {prefix: true}
    }

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
    joins(organization: :market_organizations).
      extending(MarketOrganization::AssociationScopes).
      excluding_deleted.
      mo_join_market_id(market_id)
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
      for_sort_by_price(direction)
    when "stock"
      for_sort_by_stock(direction)
    when "seller"
      order_by_seller_name(direction)
    when "market"
      joins(organization: {market_organizations: :market}).order_by_market_name(direction)
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
    organization.original_market.name
  end

  def net_percent
    @net_percent ||= organization.original_market.seller_net_percent # TODO not this (?)
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
      end.values.sort {|a, b| a.min_quantity <=> b.min_quantity }
    else
      prices.where(market_id: [market.id, nil], organization_id: [organization.id, nil]).
        order("min_quantity, organization_id desc nulls first").
        index_by {|price| price.min_quantity }.values
    end
  end

  def disable_advanced_inventory(market)
    advanced_inventory = organization.markets.reject{|m| m == market }.any? {|m| m.reload.plan.advanced_inventory }
    if !advanced_inventory && lots.count > 1
      update_column(:use_simple_inventory, true)
      current_available_inventory = available_inventory
      lots.delete_all
      lots.build(quantity: current_available_inventory).save
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

  def self.for_sort_by_price(direction)
    joins("left outer join prices on products.id = prices.product_id").
      select("products.*, coalesce(MAX(prices.sale_price), 0) as price").
      group("products.id").order_by_price(direction)
  end

  def self.for_sort_by_stock(direction)
    lot = Lot.arel_table
    expires_condition = lot[:expires_at].gt(Time.current).or(lot[:expires_at].eq(nil))
    good_from = lot[:good_from].lt(Time.current).or(lot[:good_from].eq(nil))
    joins("LEFT OUTER JOIN lots ON products.id = lots.product_id AND #{expires_condition.and(good_from).to_sql}").
      select("products.*, SUM(lots.quantity) as stock").
      group("products.id").order_by_stock(direction)
  end

  def ensure_organization_can_sell
    unless organization.present? && organization.can_sell?
      errors.add(:organization, "must be able to sell products")
    end
  end

  def update_cached_categories
    if category_id_changed?
      self.top_level_category = category.top_level_category
      self.second_level_category = category.self_and_ancestors.find_by(depth: 2)
    end
  end

  def overrides_organization?
    who_story.present? || how_story.present?
  end

  def update_delivery_schedules
    markets = organization.all_markets.excluding_deleted

    if use_all_deliveries?
      self.delivery_schedule_ids = markets.map do |market|
        market.delivery_schedules.visible.map(&:id)
      end.flatten
    else
      ids = markets.map(&:id)
      self.delivery_schedules = delivery_schedules.select {|ds| ids.include?(ds.market.id) }
    end
  end

  def update_general_product
    if self.general_product.present?
      self.general_product.update!(
        name: self.name,
        who_story: self.who_story,
        how_story: self.how_story,
        location_id: self.location_id,
        image_uid: self.image_uid,
        top_level_category_id: self.top_level_category_id,
        short_description: self.short_description,
        long_description: self.long_description,
        use_all_deliveries: self.use_all_deliveries,
        thumb_uid: self.thumb_uid,
        second_level_category_id: self.second_level_category_id
      )
    else
      gp = GeneralProduct.new(
        name: self.name,
        who_story: self.who_story,
        how_story: self.how_story,
        location_id: self.location_id,
        image_uid: self.image_uid,
        top_level_category_id: self.top_level_category_id,
        short_description: self.short_description,
        long_description: self.long_description,
        use_all_deliveries: self.use_all_deliveries,
        thumb_uid: self.thumb_uid,
        second_level_category_id: self.second_level_category_id
      )
      gp.product << self
      gp.save!
    end
  end

end
