class Market < ActiveRecord::Base
  validates :name, :subdomain, presence: true, uniqueness: true, length: {maximum: 255, allow_blank: true}
  validates :subdomain, exclusion: {in: %w(app www mail ftp smtp imap docs calendar community service support)}
  validates :tagline, length: {maximum: 255, allow_blank: true}
  validates :local_orbit_seller_fee, :local_orbit_market_fee, :market_seller_fee, :credit_card_seller_fee, :credit_card_market_fee, :ach_seller_fee, :ach_market_fee, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100, allow_blank: true}
  validates :ach_fee_cap, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 10_000, allow_blank: true}
  validates :contact_name, :contact_email, presence: true

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_cross_sells, class_name: "MarketCrossSells", foreign_key: :source_market_id
  has_many :cross_sells, through: :market_cross_sells

  has_many :market_organizations
  has_many :organizations, through: :market_organizations
  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market
  has_many :orders
  has_many :newsletters

  has_many :bank_accounts, as: :bankable

  serialize :twitter, TwitterUser

  dragonfly_accessor :logo
  dragonfly_accessor :photo

  scope_accessible :sort, method: :for_sort, ignore_blank: true

  def self.for_sort(order)
    column, direction = order.split(":")
    case column
    when "contact"
      order("contact_name #{direction}")
    else
      order("#{column} #{direction}")
    end
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
    delivery_schedules.map(&:next_delivery).min {|a,b| a.deliver_on <=> b.deliver_on }
  end

  def upcoming_deliveries_for_user(user)
    scope = deliveries.future.with_orders.order("deliver_on")
    scope = scope.with_orders_for_user(user) unless user.market_manager? || user.admin?
    scope
  end
end
