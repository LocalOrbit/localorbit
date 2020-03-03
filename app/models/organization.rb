class Organization < ActiveRecord::Base
  audited allow_mass_assignment: true
  extend DragonflyBackgroundResize
  include Sortable
  include PgSearch

  ORG_TYPES = [
    TYPE_BUYER    = 'B',
    TYPE_SUPPLIER = 'S',
    TYPE_MARKET   = 'M',
    TYPE_ADMIN    = 'A'
  ]

  before_update :process_plan_change, if: :plan_id_changed?

  has_one  :market
  has_many :market_organizations
  has_many :user_organizations

  has_many :users, through: :user_organizations
  has_many :all_markets, -> { extending(MarketOrganization::AssociationScopes).excluding_deleted },
           through: :market_organizations,
           source: :market

  has_many :markets, -> { extending(MarketOrganization::AssociationScopes).excluding_deleted.not_cross_selling },
           through: :market_organizations

  has_many :cross_sells, -> { extending(MarketOrganization::AssociationScopes).excluding_deleted.cross_selling },
           through: :market_organizations,
           source: :market

  has_many :orders, inverse_of: :organization

  has_many :products, inverse_of: :organization, autosave: true, dependent: :destroy
  has_many :general_products, inverse_of: :organization, autosave: true, dependent: :destroy
  has_many :carts

  has_many :locations, inverse_of: :organization, dependent: :destroy

  has_many :bank_accounts, as: :bankable, dependent: :destroy

  belongs_to :plan, inverse_of: :organizations
  belongs_to :plan_bank_account, class_name: "BankAccount"

  validates :org_type, inclusion: { in: ORG_TYPES }
  validates :name, presence: true, length: {maximum: 255, allow_blank: true}
  validate :require_payment_method

  scope :active,  -> { where(active: true) }
  scope :selling, -> { where(org_type: TYPE_SUPPLIER) }
  scope :buying,  -> { where(org_type: TYPE_BUYER) }
  scope :visible, -> { where(show_profile: true) }
  scope :with_products, -> { joins(:products).select("DISTINCT organizations.*").order(name: :asc) }
  scope :buyers_for_orders, lambda {|orders| joins(:orders).where(orders: {id: orders}).uniq }
  scope :with_a_market, -> { joins(user_organizations: {organization: :markets}).group("organizations.id") }
  scope :for_products, lambda {|products| joins(:products).where(products: {id: products}).uniq }

  scope :not_deleted, -> { joins(:markets) }

  serialize :twitter, TwitterUser

  accepts_nested_attributes_for :locations, reject_if: :reject_location

  dragonfly_accessor :photo
  define_after_upload_resize(:photo, 1200, 1200)
  validates_property :format, of: :photo, in: %w(jpg jpeg png gif)

  scope_accessible :market, method: :for_market_id, ignore_blank: true
  scope_accessible :can_sell, method: :for_can_sell, ignore_blank: true
  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :search, method: :for_search, ignore_blank: true

  pg_search_scope :search_by_name, against: :name, using: {tsearch: {prefix: true}}

  def self.for_search(query)
    search_by_name(query)
  end

  def self.for_market_id(market_id)
    orgs = !all.to_sql.include?("market_organizations") ? joins(:market_organizations) : all
    orgs.where(market_organizations: {market_id: [market_id]})
  end

  def self.for_can_sell(can_sell)
    where(can_sell: can_sell)
  end

  def self.arel_column_for_sort(column_name)
    case column_name
    when "can_sell"   then arel_table[:can_sell]
    when "registered" then arel_table[:created_at]
    else
      arel_table[:name]
    end
  end

  def self.managed_by_market_ids(market_ids)
    select("organizations.*").
    joins(:market_organizations).
    where(market_organizations: {market_id: market_ids}).
    where(market_organizations: {cross_sell_origin_market_id: nil})
  end

  def self.all_for_market_ids(market_ids)
    select("organizations.*").
    joins(:market_organizations).
    where(market_organizations: {market_id: market_ids})
  end

  def shipping_location
    locations.visible.default_shipping
  end

  def billing_location
    locations.visible.default_billing
  end

  def can_cross_sell?
    can_sell? && markets.joins(:organization => [:plan]).where(allow_cross_sell: true, plans: {cross_selling: true}).any?
  end

  def buyer?
    org_type == TYPE_BUYER
  end

  def supplier?
    org_type == TYPE_SUPPLIER
  end

  def update_product_delivery_schedules
    reload.products.each(&:save) if persisted?
  end

  def update_cross_sells!(from_market: nil, to_ids: [])
    ids = to_ids.map(&:to_i)

    original_cross_sells  = market_organizations.visible.where(cross_sell_origin_market: from_market)
    cross_sells_to_remove = original_cross_sells.where.not(market_id: ids)
    new_cross_sell_ids = ids - original_cross_sells.map(&:market_id)

    # Create the new ones
    new_cross_sell_ids.each do |new_cross_sell_id|
      market_organizations.create(market_id: new_cross_sell_id, cross_sell_origin_market: from_market)
    end

    # Destroy the old ones
    cross_sells_to_remove.soft_delete_all
    update_product_delivery_schedules
  end

  def original_market
    (markets.includes(:markets).empty? ? cross_sells : markets).order("market_organizations.id ASC").first
  end

  def cross_selling?(from: nil, to: nil)
    market_organizations.excluding_deleted.where(cross_sell_origin_market: from, market: to).exists?
  end

  def has_market?
    markets.any?
  end

  def primary_payment_provider
    if m = markets.first
      m.primary_payment_provider
    else
      nil
    end
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id) if stripe_customer_id
  end

  def all_markets_for_select
    all_markets.map do |market|
      [market.name, market.id]
    end
  end

  def adjunct_organization
    # This should probably be boiled down to a single 'master market' flag...
    !(plan_start_at && plan_interval)
  end

  def next_service_payment_at
    return nil if adjunct_organization

    return plan_start_at if plan_start_at > Time.now
    return plan_start_at if last_service_payment_at.nil?
    return plan_start_at if plan_start_at.to_datetime > last_service_payment_at.to_datetime

    @next_service_payment_at ||= plan_interval.months.from_now(last_service_payment_at)
  end

  def last_service_payment_at
    Payment.successful.not_refunded.where(payer: self, payment_type: "service").order("created_at DESC").first.try(:created_at)
  end

  def subscription_eligible?
    !subscribed && next_service_payment_at && next_service_payment_at <= Time.now
  end

  def subscribe!
    update!(subscribed: true)
  end

  def set_subscription(subscription, provider='stripe')
    plan = Plan.where(stripe_id: subscription.plan.id).first
    h = {
      plan_id: plan.id,
      plan_fee: ::Financials::MoneyHelpers.cents_to_amount(subscription.plan.amount),
      plan_interval: translate_interval(subscription.plan.interval),
      plan_start_at: Time.at(subscription.created).to_datetime,
      subscribed: true,
      subscription_id: subscription.id,
      subscription_status: subscription.status,
      payment_provider: provider
    }
    update_attributes(h)
  end

  def unset_subscription(source)
    h = {
      plan_id: source.plan_id,
      plan_fee: source.plan_fee,
      plan_interval: source.plan_interval,
      plan_start_at: source.plan_start_at,
      subscribed: source.subscribed,
      subscription_id: source.subscription_id,
      subscription_status: source.subscription_status,
    }
    update_attributes(h)
  end

  def display_plan_interval
    if plan_interval == 1
      "Monthly"
    elsif plan_interval == 12
      "Yearly"
    else
      "Not Set"
    end
  end

  private

  def translate_interval(interval)
    return 1 if interval == "month"
    return 12 if interval == "year"
    return nil
  end


  def reject_location(attributed)
    #attributed["name"].blank? ||
    attributed["address"].blank? ||
      attributed["city"].blank? ||
      attributed["state"].blank? ||
      attributed["zip"].blank?
  end

  def require_payment_method
    unless self.org_type == TYPE_MARKET || allow_purchase_orders? || allow_credit_cards? || allow_ach?
      errors.add(:payment_method, "At least one payment method is required for the organization")
    end
  end

  def process_plan_change
    market.remove_cross_selling_from_market unless plan.cross_selling
    market.products.each {|p| p.disable_advanced_inventory(self.market) } unless plan.advanced_inventory
  end

end
