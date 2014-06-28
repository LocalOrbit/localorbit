class Market < ActiveRecord::Base
  include Sortable
  validates :name, :subdomain, presence: true, uniqueness: true, length: {maximum: 255, allow_blank: true}
  validates :subdomain, exclusion: {in: %w(app www mail ftp smtp imap docs calendar community knowledge service support)}
  validates :tagline, length: {maximum: 255, allow_blank: true}
  validates :local_orbit_seller_fee, :local_orbit_market_fee, :market_seller_fee, :credit_card_seller_fee, :credit_card_market_fee, :ach_seller_fee, :ach_market_fee, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100, allow_blank: true}
  validates :ach_fee_cap, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 10_000, allow_blank: true}
  validates :contact_name, :contact_email, presence: true

  validate :require_payment_method

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_cross_sells, class_name: "MarketCrossSells", foreign_key: :source_market_id
  has_many :cross_sells, through: :market_cross_sells

  has_many :market_organizations, -> { where(deleted_at: nil) }
  has_many :organizations, through: :market_organizations
  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market
  has_many :orders
  has_many :newsletters
  has_many :promotions, inverse_of: :market
  belongs_to :plan, inverse_of: :markets

  has_many :bank_accounts, as: :bankable

  serialize :twitter, TwitterUser

  dragonfly_accessor :logo
  dragonfly_accessor :photo

  scope_accessible :sort, method: :for_sort, ignore_blank: true

  def self.for_sort(order)
    column, direction = column_and_direction(order)
    case column
    when "contact"
      order_by_contact_name(direction)
    when "name"
      order_by_name(direction)
    when "subdomain"
      order_by_subdomain(direction)
    else
      order_by_name(direction)
    end
  end

  def self.for_order_items(order_items)
    joins(:orders).where(orders: { id: order_items.map(&:order_id) }).uniq
  end

  def balanced_customer
    Balanced::Customer.find(balanced_customer_uri)
  end

  def fulfillment_locations(default_name)
    addresses.order(:name).map {|a| [a.name, a.id] }.unshift([default_name, 0])
  end

  def domain
    "#{subdomain}.#{Figaro.env.domain!}"
  end

  # TODO: exclude fees for payment types not available on the market
  def seller_net_percent
    BigDecimal("1") - (local_orbit_seller_fee + market_seller_fee + [ach_seller_fee, credit_card_seller_fee].max) / 100
  end

  def products
    Product.where(organization_id: organizations.pluck(:id))
  end

  def deliveries
    Delivery.for_market(self)
  end

  def next_delivery
    delivery_schedules.visible.map(&:next_delivery).min {|a,b| a.deliver_on <=> b.deliver_on }
  end

  def only_delivery
    schedules = delivery_schedules.visible.to_a
    schedules.first.next_delivery if schedules.size == 1
  end

  def upcoming_deliveries_for_user(user)
    scope = deliveries.future.with_orders.order("deliver_on")
    scope = scope.with_orders_for_user(user) unless user.market_manager? || user.admin?
    scope
  end

  def featured_promotion(buyer)
    promotion = promotions.active.first
    product = promotion.try(:product)

    if product.present? && product.available_inventory > 0 && product.prices_for_market_and_organization(self, buyer).any?
      promotion
    else
      nil
    end
  end

  def close!
    update!(closed: true)
  end

  def open!
    update!(closed: false)
  end

  private

  def self.order_by_name(direction)
    direction == "asc" ? order("name asc") : order("name desc")
  end

  def self.order_by_subdomain(direction)
    direction == "asc" ? order("subdomain asc") : order("subdomain desc")
  end

  def self.order_by_contact_name(direction)
    direction == "asc" ? order("contact_name asc") : order("contact_name desc")
  end

  def require_payment_method
    unless allow_purchase_orders? || allow_credit_cards? || allow_ach?
      self.errors.add(:payment_method, "At least one payment method is required for the market")
    end
  end
end
