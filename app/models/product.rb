class Product < ActiveRecord::Base
  extend DragonflyBackgroundResize
  include SoftDelete
  include PgSearch
  include Sortable

  before_save :update_cached_categories
  before_save :update_delivery_schedules
  before_save :update_general_product
  audited allow_mass_assignment: true, associated_with: :organization

  belongs_to :category
  belongs_to :top_level_category, class: Category
  belongs_to :second_level_category, class: Category
  belongs_to :organization, inverse_of: :products
  belongs_to :location
  belongs_to :unit
  belongs_to :external_product, inverse_of: :product
  belongs_to :general_product
  default_scope { includes(:general_product) }

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

  ### GETTERS ###
  def name
    self.general_product && self.general_product.name
  end
  def category_id
    self.general_product && self.general_product.category_id
  end
  def organization_id
    self.general_product && self.general_product.organization_id
  end
  def who_story
    self.general_product && self.general_product.who_story
  end
  def how_story
    self.general_product && self.general_product.how_story
  end
  def location_id
    self.general_product && self.general_product.location_id
  end
  # def image_uid
  #   self.general_product && self.general_product.image_uid
  # end
  def top_level_category_id
    self.general_product && self.general_product.top_level_category_id
  end
  def short_description
    self.general_product && self.general_product.short_description
  end
  def long_description
    self.general_product && self.general_product.long_description
  end
  def use_all_deliveries
    if self.general_product
      self.general_product.use_all_deliveries
    else
      true # Default
    end
  end
  def thumb_uid
    self.general_product && self.general_product.thumb_uid
  end
  def second_level_category_id
    self.general_product && self.general_product.second_level_category_id
  end

  ### SETTERS ###
  def name=(input)
    write_attribute(:name, input)
    ensure_product_has_a_general_product
    self.general_product.name = input
    input
  end
  def category_id=(input)
    write_attribute(:category_id, input)
    ensure_product_has_a_general_product
    self.general_product.category_id = input
  end
  def category=(input)
    ensure_product_has_a_general_product
    self.general_product.category_id = if input.present?
      input.id
    else
      nil
    end
    association(:category).writer(input)
  end
  def organization_id=(input)
    write_attribute(:organization_id, input)
    ensure_product_has_a_general_product
    self.general_product.organization_id = input
  end
  def organization=(input)
    ensure_product_has_a_general_product
    self.general_product.organization_id = if input.present?
      input.id
    else
      nil
    end
    association(:organization).writer(input)
  end
  def who_story=(input)
    write_attribute(:who_story, input)
    ensure_product_has_a_general_product
    self.general_product.who_story = input
  end
  def how_story=(input)
    write_attribute(:how_story, input)
    ensure_product_has_a_general_product
    self.general_product.how_story = input
  end
  def location_id=(input)
    write_attribute(:location_id, input)
    ensure_product_has_a_general_product
    self.general_product.location_id = input
  end
  def location=(input)
    ensure_product_has_a_general_product
    self.general_product.location_id = if input.present?
      input.id
    else
      nil
    end
    association(:location).writer(input)
  end
  # def image_uid=(input)
  #   write_attribute(:image_uid, input)
  #   ensure_product_has_a_general_product
  #   self.general_product.image_uid = input
  # end
  def top_level_category_id=(input)
    write_attribute(:top_level_category_id, input)
    ensure_product_has_a_general_product
    self.general_product.top_level_category_id = input
  end
  def top_level_category=(input)
    ensure_product_has_a_general_product
    self.general_product.top_level_category_id = if input.present?
      input.id
    else
      nil
    end
    association(:top_level_category).writer(input)
  end
  def short_description=(input)
    write_attribute(:short_description, input)
    ensure_product_has_a_general_product
    self.general_product.short_description = input
  end
  def long_description=(input)
    write_attribute(:long_description, input)
    ensure_product_has_a_general_product
    self.general_product.long_description = input
  end
  def use_all_deliveries=(input)
    write_attribute(:use_all_deliveries, input)
    ensure_product_has_a_general_product
    self.general_product.use_all_deliveries = input
  end
  def thumb_uid=(input)
    write_attribute(:thumb_uid, input)
    ensure_product_has_a_general_product
    self.general_product.thumb_uid = input
  end
  def second_level_category_id=(input)
    write_attribute(:second_level_category_id, input)
    ensure_product_has_a_general_product
    self.general_product.second_level_category_id = input
  end
  def second_level_category=(input)
    ensure_product_has_a_general_product
    self.general_product.second_level_category_id = if input.present?
      input.id
    else
      nil
    end
    association(:second_level_category).writer(input) 
  end
  def general_product_id=(input)
    gp = GeneralProduct.find(input)
    if gp
      self.general_product = gp
    else
      self.general_product.id = input
      write_attribute(:general_product_id, input)
    end
  end
  def general_product=(input)
    association(:general_product).writer(input)
    self.general_product.assign_attributes(input.as_json)
  end

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
  def self.available_for_sale(market, buyer=nil, deliver_on_date=Time.current.end_of_minute)
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

  def self.with_available_inventory(deliver_on_date=Time.current.end_of_minute)
    lot_table = Lot.arel_table
    on_cond = arel_table[:id].eq(lot_table[:product_id]).
              and(lot_table[:good_from].eq(nil).or(lot_table[:good_from].lt(deliver_on_date))).
              and(lot_table[:expires_at].eq(nil).or(lot_table[:expires_at].gt(deliver_on_date))).
              and(lot_table[:quantity].gt(0))
    join_on = arel_table.create_on(on_cond)

    joins(arel_table.create_join(Lot.arel_table, join_on))
  end

  def can_use_simple_inventory?
    use_simple_inventory? || !lots.where("(expires_at IS NULL OR expires_at > ?) AND quantity > 0", Time.current.end_of_minute).exists?
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

  def available_inventory(deliver_on_date=Time.current.end_of_minute)
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

  def ensure_product_has_a_general_product
    unless self.general_product
      self.general_product = GeneralProduct.new
      self.general_product.use_all_deliveries = true
      self.general_product.product << self
    end
  end

  def update_general_product
    ensure_product_has_a_general_product
    self.general_product.save!
  end
  
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
    expires_condition = lot[:expires_at].gt(Time.current.end_of_minute).or(lot[:expires_at].eq(nil))
    good_from = lot[:good_from].lt(Time.current.end_of_minute).or(lot[:good_from].eq(nil))
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

    if self.use_all_deliveries?
      self.delivery_schedule_ids = markets.map do |market|
        market.delivery_schedules.visible.map(&:id)
      end.flatten
    else
      ids = markets.map(&:id)
      self.delivery_schedules = delivery_schedules.select {|ds| ids.include?(ds.market.id) }
    end
  end

end
