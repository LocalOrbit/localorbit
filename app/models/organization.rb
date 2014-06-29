class Organization < ActiveRecord::Base
  include Sortable
  include PgSearch

  has_many :market_organizations, -> { where(deleted_at: nil) }
  has_many :user_organizations

  has_many :users, through: :user_organizations
  has_many :all_markets, through: :market_organizations, source: :market
  has_many :markets, -> { where(market_organizations: { cross_sell: false }) }, through: :market_organizations
  has_many :cross_sells, -> { where(market_organizations: { cross_sell: true }) }, through: :market_organizations, source: :market, after_add: :update_product_delivery_schedules, after_remove: :update_product_delivery_schedules
  has_many :orders, inverse_of: :organization

  has_many :products, inverse_of: :organization, autosave: true, dependent: :destroy
  has_many :carts

  has_many :locations, inverse_of: :organization, dependent: :destroy

  has_many :bank_accounts, as: :bankable, dependent: :destroy

  validates :name, presence: true, length: {maximum: 255, allow_blank: true}
  validate :require_payment_method

  scope :selling, -> { where(can_sell: true) }
  scope :buying,  -> { where(can_sell: false) } # needs a new boolean
  scope :visible, -> { where(show_profile: true) }
  scope :with_products, -> { joins(:products).select("DISTINCT organizations.*").order(name: :asc) }
  scope :buyers_for_orders, ->(orders) { joins(:orders).where(orders: { id: orders }).uniq }

  serialize :twitter, TwitterUser

  accepts_nested_attributes_for :locations, reject_if: :reject_location

  dragonfly_accessor :photo

  scope_accessible :market, method: :for_market_id, ignore_blank: true
  scope_accessible :can_sell, method: :for_can_sell, ignore_blank: true
  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  pg_search_scope :search_by_name, against: :name, using: { tsearch: { prefix: true }}

  def self.for_search(query)
    search_by_name(query)
  end

  def self.for_market_id(market_id)
    orgs = !all.to_sql.include?('market_organizations') ? joins(:market_organizations) : all
    orgs.where(market_organizations: { market_id: [market_id] })
  end

  def self.for_can_sell(can_sell)
    where(can_sell: can_sell)
  end

  def self.for_sort(order)
    column, direction = column_and_direction(order)
    case column
    when "can_sell"
      order_by_can_sell(direction)
    when "registered"
      order_by_registered(direction)
    else
      order_by_name(direction)
    end
  end

  def shipping_location
    locations.visible.default_shipping
  end

  def billing_location
    locations.visible.default_billing
  end

  def can_cross_sell?
    can_sell? && markets.joins(:plan).where(allow_cross_sell: true, plans: {cross_selling: true }).any?
  end

  def update_product_delivery_schedules(market)
    reload.products.each(&:save) if persisted?
  end

  def balanced_customer
    Balanced::Customer.find(balanced_customer_uri)
  end

  private

  def self.order_by_name(direction)
    direction == "asc" ? order("name asc") : order("name desc")
  end

  def self.order_by_registered(direction)
    direction == "asc" ? order("created_at asc") : order("created_at desc")
  end

  def self.order_by_can_sell(direction)
    direction == "asc" ? order("can_sell asc") : order("can_sell desc")
  end

  def reject_location(attributed)
    attributed['name'].blank? ||
      attributed['address'].blank? ||
      attributed['city'].blank? ||
      attributed['state'].blank? ||
      attributed['zip'].blank?
  end

  def require_payment_method
    unless allow_purchase_orders? || allow_credit_cards? || allow_ach?
      self.errors.add(:payment_method, "At least one payment method is required for the organization")
    end
  end
end
