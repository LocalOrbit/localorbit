class Market < ActiveRecord::Base
  attr_accessor :stripe_tok

  before_update :process_cross_sells_change, if: :allow_cross_sell_changed?

  audited allow_mass_assignment: true
  extend DragonflyBackgroundResize
  include Sortable
  include Util::TrimText
  include PgSearch

  paginates_per 50

  trimmed_fields :contact_email

  validates :name, :subdomain, presence: true, uniqueness: true, length: {maximum: 255, allow_blank: true}
  validates :subdomain, exclusion: {in: %w(app www mail ftp smtp imap docs calendar community knowledge service support)}
  validates :tagline, length: {maximum: 255, allow_blank: true}
  validates :local_orbit_seller_fee, :local_orbit_market_fee, :market_seller_fee, :credit_card_seller_fee, :credit_card_market_fee, :ach_seller_fee, :ach_market_fee, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100, allow_blank: true}
  validates :ach_fee_cap, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 10_000, allow_blank: true}
  validates :contact_name, :contact_email, :country, presence: true
  validates :po_payment_term, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 366}

  validate :require_payment_method

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_cross_sells, class_name: "MarketCrossSells", foreign_key: :source_market_id
  has_many :cross_sells, through: :market_cross_sells

  has_many :cross_selling_lists, as: :entity

  has_many :categories, -> { distinct }, through: :supplier_products
  has_many :supplier_products, class_name: "Product", through: :suppliers, source: :products
  has_many :suppliers, -> { where(active: true, can_sell: true) }, class_name: "Organization", through: :market_organizations, source: :organization

  has_many :market_organizations
  has_many :organizations, -> { extending(MarketOrganization::AssociationScopes).excluding_deleted }, through: :market_organizations # XXX prefer the merge in the line below to this partially and incorrectly implemened .excluding_deleted scope?
  # TODO has_many :organizations, -> { merge(MarketOrganization.visible) }, through: :market_organizations

  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market
  has_many :orders
  has_many :newsletters
  has_many :promotions, inverse_of: :market
  has_many :order_templates
  belongs_to :organization

  has_many :bank_accounts, as: :bankable

  serialize :twitter, TwitterUser

  dragonfly_accessor :logo
  dragonfly_accessor :photo
  define_after_upload_resize(:logo, 1200, 1200)
  define_after_upload_resize(:photo, 1800, 1800)
  validates_property :format, of: :logo,  in: %w(jpg jpeg png gif)
  validates_property :format, of: :photo, in: %w(jpg jpeg png gif)

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  pg_search_scope :search_by_name, against: :name, using: {tsearch: {prefix: true}}

  scope :active, -> { where(active: true) }
  scope :managed_by, lambda { |user|
    if user.admin?
      all
    else
      where(id: user.managed_markets.pluck(:id))
    end
  }

  def self.for_search(query)
    search_by_name(query)
  end

  def self.possible_countries
    [['United States', 'US'], ['Canada', 'CA']]
  end

  def self.arel_column_for_sort(column_name)
    case column_name
    when "contact"   then arel_table[:contact_name]
    when "subdomain" then arel_table[:subdomain]
    else
      arel_table[:name]
    end
  end

  def self.for_order_items(order_items)
    joins(:orders).where(orders: {id: order_items.map(&:order_id)}).uniq
  end

  def pretty_email
    "#{contact_name.to_s.inspect} <#{contact_email}>"
  end

  #
  # NOTE: We're transitioning from per-market payment fee config to provider-based payment structures.
  # We still need to indicate whether Market or Seller must pay, so for now we're re-using the
  # existing numeric fee fields to determine who's paying.  TODO: cleanup and remodel the markets table
  # to better represent what's actually going on.
  #
  def credit_card_payment_fee_payer
    credit_card_market_fee != 0 ? 'market' : 'seller'
  end

  def set_credit_card_payment_fee_payer(payer_string)
    payment_fees = {
      credit_card_market_fee: 0,
      credit_card_seller_fee: 0,
      ach_market_fee: 0,
      ach_seller_fee: 0,
    }
    if payer_string == 'market'
      payment_fees[:credit_card_market_fee] = 1 # amount is irrelevant; this just needs to be non-zero
    else
      payment_fees[:credit_card_seller_fee] = 1
    end

    self.update(payment_fees)
  end

  def balanced_customer
    Balanced::Customer.find(balanced_customer_uri)
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id
  end

  def stripe_account
    Stripe::Account.retrieve(stripe_account_id) if stripe_account_id
  rescue Exception => e
    nil
  end

  def fulfillment_locations(default_name, secondary_name=nil)
    loc = addresses.visible.order(:name).map {|a| [a.name, a.id] }
    if secondary_name
      loc.unshift([secondary_name, 0]).unshift([default_name, 0])
    else
      loc.unshift([default_name, 0])
    end
  end

  def domain
    "#{subdomain}.#{Figaro.env.domain!}"
  end

  def seller_net_percent
    subtract_amt = (local_orbit_seller_fee + market_seller_fee)/100 # These fees come as rates, numbers 100x bigger and need to be converted to percents
    cc_rate = PaymentProvider.approximate_credit_card_rate(payment_provider)
    if credit_card_payment_fee_payer == 'seller' and allow_credit_cards?
      subtract_amt += BigDecimal(cc_rate)
    end
    (BigDecimal(1) - subtract_amt)
  end

  # LO's % take as a true decimal: eg, if local_orbit_seller_fee = 2.0 and local_orbit_market_fee  = 1.0 then this method returns 0.03 as a BigDecimal
  def local_orbit_seller_and_market_fee_fraction
    (local_orbit_seller_fee + local_orbit_market_fee) / 100
  end

  def products
    Product.where(organization_id: organizations.pluck(:id))
  end

  def deliveries
    Delivery.for_market(self)
  end

  def next_delivery
    delivery_schedules.delivery_visible.map(&:next_delivery).min {|a, b| a.deliver_on <=> b.deliver_on }
  end

  def only_delivery
    schedules = delivery_schedules.delivery_visible.to_a
    schedules.first.next_delivery if schedules.size == 1
  end

  def upcoming_deliveries_for_user(user)
    scope = deliveries.future.with_undelivered_orders.order("deliver_on")
    scope = scope.with_undelivered_orders_for_user(user) unless user.market_manager? || user.admin?
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

  def on_statement_as
    name.sub(/[^0-9a-zA-Z\.\-_ \^\`\|]/, '')[0, 22]
  end

  def primary_payment_provider
    self.payment_provider
  end

  def deposit_account
    self.bank_accounts.visible.deposit_accounts.first
  end

  def remove_cross_selling_from_market
    update_column(:allow_cross_sell, false)

    MarketOrganization.
        where(cross_sell_origin_market_id: id).
        each(&:soft_delete)

    MarketOrganization.
        where.not(cross_sell_origin_market_id: nil).
        where(market_id: id).
        each(&:soft_delete)

    MarketCrossSells.where(source_market_id: id).destroy_all
  end

  # Called as the last in a scope chain
  def self.sort_service_payment
    all.sort do |a,b|
      if a.organization.next_service_payment_at && b.organization.next_service_payment_at
        a.organization.next_service_payment_at <=> b.organization.next_service_payment_at
      elsif a.organization.next_service_payment_at.nil? && b.organization.next_service_payment_at.nil?
        a.name.downcase <=> b.name.downcase
      elsif a.organization.next_service_payment_at.nil?
        -1 # Means order is wrong
      else
        1 # Means order is correct
      end
    end
  end

  private

  def require_payment_method
    unless allow_purchase_orders? || allow_credit_cards? || allow_ach?
      errors.add(:payment_method, "At least one payment method is required for the market")
    end
  end

  def process_cross_sells_change
    remove_cross_selling_from_market unless allow_cross_sell?
  end


end
