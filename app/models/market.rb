class Market < ActiveRecord::Base
  before_update :process_cross_sells_change, if: :allow_cross_sell_changed?
  before_update :process_plan_change, if: :plan_id_changed?

  audited allow_mass_assignment: true
  extend DragonflyBackgroundResize
  include Sortable

  validates :name, :subdomain, presence: true, uniqueness: true, length: {maximum: 255, allow_blank: true}
  validates :subdomain, exclusion: {in: %w(app www mail ftp smtp imap docs calendar community knowledge service support)}
  validates :tagline, length: {maximum: 255, allow_blank: true}
  validates :local_orbit_seller_fee, :local_orbit_market_fee, :market_seller_fee, :credit_card_seller_fee, :credit_card_market_fee, :ach_seller_fee, :ach_market_fee, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 100, allow_blank: true}
  validates :ach_fee_cap, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 10_000, allow_blank: true}
  validates :contact_name, :contact_email, presence: true
  validates :po_payment_term, presence: true, numericality: {greater_than_or_equal_to: 0, less_than: 366}

  validate :require_payment_method

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  has_many :market_cross_sells, class_name: "MarketCrossSells", foreign_key: :source_market_id
  has_many :cross_sells, through: :market_cross_sells

  has_many :market_organizations
  has_many :organizations, -> { extending(MarketOrganization::AssociationScopes).excluding_deleted }, through: :market_organizations # XXX prefer the merge in the line below to this partially and incorrectly implemened .excluding_deleted scope?
  # TODO has_many :organizations, -> { merge(MarketOrganization.visible) }, through: :market_organizations

  has_many :addresses, class_name: MarketAddress
  has_many :delivery_schedules, inverse_of: :market
  has_many :orders
  has_many :newsletters
  has_many :promotions, inverse_of: :market
  belongs_to :plan, inverse_of: :markets
  belongs_to :plan_bank_account, class_name: "BankAccount"

  has_many :bank_accounts, as: :bankable

  serialize :twitter, TwitterUser

  dragonfly_accessor :logo
  dragonfly_accessor :photo
  define_after_upload_resize(:logo, 1200, 1200)
  define_after_upload_resize(:photo, 1800, 1800)
  validates_property :format, of: :logo,  in: %w(jpeg png gif)
  validates_property :format, of: :photo, in: %w(jpeg png gif)

  scope_accessible :sort, method: :for_sort, ignore_blank: true

  scope :active, -> { where(active: true) }
  scope :managed_by, lambda { |user|
    if user.admin?
      all
    else
      where(id: user.managed_markets.pluck(:id))
    end
  }

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

  # Called as the last in a scope chain
  def self.sort_service_payment
    all.sort do |a,b|
      if a.next_service_payment_at && b.next_service_payment_at
        a.next_service_payment_at <=> b.next_service_payment_at
      elsif a.next_service_payment_at.nil? && b.next_service_payment_at.nil?
        a.name.downcase <=> b.name.downcase
      elsif a.next_service_payment_at.nil?
        -1 # Means order is wrong
      else
        1 # Means order is correct
      end
    end
  end

  def credit_card_payment_fee_payer
    credit_card_seller_fee == 0 ? 'market' : 'seller'
  end

  def balanced_customer
    Balanced::Customer.find(balanced_customer_uri)
  end

  def fulfillment_locations(default_name)
    addresses.visible.order(:name).map {|a| [a.name, a.id] }.unshift([default_name, 0])
  end

  def domain
    "#{subdomain}.#{Figaro.env.domain!}"
  end

  # TODO: exclude fees for payment types not available on the market
  def seller_net_percent
    BigDecimal("1") - (local_orbit_seller_fee + market_seller_fee + [ach_seller_fee, credit_card_seller_fee].max) / 100
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
    delivery_schedules.visible.map(&:next_delivery).min {|a, b| a.deliver_on <=> b.deliver_on }
  end

  def only_delivery
    schedules = delivery_schedules.visible.to_a
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

  def next_service_payment_at
    return nil unless plan_start_at && plan_interval
    return plan_start_at if plan_start_at > Time.now

    @next_service_payment_at ||= begin
      plan_payments = Payment.successful.not_refunded.made_after(plan_start_at).where(payer: self, payment_type: "service")
      (plan_interval * plan_payments.count).months.from_now(plan_start_at)
    end
  end

  def last_service_payment_at
    Payment.successful.not_refunded.where(payer: self, payment_type: "service").order("created_at DESC").first.try(:created_at)
  end

  def plan_payable?
    plan_fee && plan_fee > 0 && plan_bank_account.try(:usable_for?, :debit)
  end

  def on_statement_as
    name.sub(/[^0-9a-zA-Z\.\-_ \^\`\|]/, '')[0, 22]
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

  def process_plan_change
    remove_cross_selling_from_market unless plan.cross_selling
    products.each {|p| p.disable_advanced_inventory(self) } unless plan.advanced_inventory
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
end
