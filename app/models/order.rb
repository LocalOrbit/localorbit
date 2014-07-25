class Order < ActiveRecord::Base
  INVOICE_STATUSES = %w(due overdue).freeze

  include SoftDelete
  include DeliveryStatus
  include Sortable

  attr_accessor :credit_card, :bank_account

  belongs_to :market, inverse_of: :orders
  belongs_to :organization, inverse_of: :orders
  belongs_to :delivery, inverse_of: :orders
  belongs_to :placed_by, class: User

  has_many :items, inverse_of: :order, class: OrderItem, autosave: true, dependent: :destroy
  has_many :order_payments, inverse_of: :order
  has_many :payments, through: :order_payments, inverse_of: :orders
  has_many :products, through: :items

  validates :billing_address, presence: true
  validates :billing_city, presence: true
  validates :billing_organization_name, presence: true
  validates :billing_state, presence: true
  validates :billing_zip, presence: true
  validates :delivery_address, presence: true
  validates :delivery_city, presence: true
  validates :delivery_fees, presence: true
  validates :delivery_id, presence: true
  validates :delivery_state, presence: true
  validates :delivery_zip, presence: true
  validates :market_id, presence: true
  validates :order_number, presence: true, uniqueness: true
  validates :organization_id, presence: true
  validates :payment_method, presence: true, inclusion: {in: Payment::PAYMENT_METHODS.keys, allow_blank: true}
  validates :payment_status, presence: true
  validates :placed_at, presence: true
  validates :total_cost, presence: true

  before_save :update_paid_at
  after_save :update_total_cost

  scope :recent, -> { visible.order("created_at DESC").limit(15) }
  scope :upcoming_delivery, -> { visible.joins(:delivery).where("deliveries.deliver_on > ?", Time.current) }
  scope :uninvoiced, -> { visible.where(payment_method: "purchase order", invoiced_at: nil) }
  scope :invoiced, -> { visible.where(payment_method: "purchase order").where.not(invoiced_at: nil) }
  scope :unpaid, -> { visible.where(payment_status: "unpaid") }
  scope :paid, -> { visible.where(payment_status: "paid") }
  scope :delivered, -> { visible.where("order_items.delivery_status = ?", "delivered").group("orders.id") }
  scope :paid_with, lambda {|method| visible.where(payment_method: method) }
  scope :payment_overdue, -> { unpaid.where("invoice_due_date < ?", (Time.current - 1.day).end_of_day) }
  scope :payment_due, -> { unpaid.where("invoice_due_date >= ?", (Time.current - 1.day).end_of_day) }
  scope :payment_status, lambda { |status|
    case status
    when "overdue"
      payment_overdue
    when "due"
      payment_due
    when "uninvoiced"
      uninvoiced
    else
      all
    end
  }
  scope :delivered_between, lambda { |range|
    delivered.
      having("MAX(order_items.delivered_at) >= ?", range.begin).
      having("MAX(order_items.delivered_at) < ?", range.end)
  }
  scope :paid_between, lambda {|range| paid.where(paid_at: range) }
  scope :due_between, lambda {|range| invoiced.where(invoice_due_date: range) }

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :payment_status

  accepts_nested_attributes_for :items, allow_destroy: true

  def self.balanced_payable_to_market
    # TODO: figure out how to make sure the orders haven't changed
    non_automate_market_ids = Market.joins(:plan).where.not(plans: {name: "Automate"}).pluck(:id)
    subselect = %(SELECT DISTINCT "order_payments"."order_id" FROM "order_payments"
      INNER JOIN "payments" ON "payments"."id" = "order_payments"."payment_id"
      WHERE "payments"."status" != 'failed' AND
            "payments"."payment_type" = 'market payment' AND
            "payments"."payee_type" = 'Market' AND
            "payments"."payee_id" = "orders"."market_id")

    where(payment_method: ["credit card", "ach", "paypal"]).
      where("orders.id NOT IN (#{subselect})").
      where("orders.placed_at > ?", 6.months.ago).
      where(market_id: non_automate_market_ids).
      joins(:delivery, :items).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      select("orders.*").
      group("orders.id").
      preload(:items, :market)
  end

  def self.payable_to_sellers
    subselect = "SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = ? AND payments.payee_id = products.organization_id"

    select("orders.*, products.organization_id as seller_id").joins(:delivery, items: :product).
      where("NOT EXISTS(#{subselect})", "Organization").
      # This is a slightly fuzzy match right now.
      # TODO: Implement delivery_end on deliveries for greater accuracy
      where("deliveries.deliver_on < ?", 48.hours.ago).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      group("orders.id, seller_id").
      order("orders.order_number").
      includes(:market)
  end

  def self.payable_lo_fees
    subselect = %(SELECT DISTINCT "order_payments"."order_id" FROM "order_payments"
      INNER JOIN "payments" ON "payments"."id" = "order_payments"."payment_id"
      WHERE "payments"."payment_type" = 'lo fee' AND "payments"."payer_type" = 'Market' AND "payments"."payer_id" = "orders"."market_id")

    joins(:delivery, :items).
      where("orders.id NOT IN (#{subselect})").
      # This is a slightly fuzzy match right now.
      # TODO: Implement delivery_end on deliveries for greater accuracy
      where("deliveries.deliver_on < ?", 48.hours.ago).
      where(payment_method: "purchase order").
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      order("orders.order_number").
      select("orders.*").
      group("orders.id")
  end

  def self.payable_market_fees
    # TODO: figure out how to make sure the orders haven't changed
    automate_market_ids = Market.joins(:plan).where(plans: {name: "Automate"}).pluck(:id)
    subselect = %(SELECT DISTINCT "order_payments"."order_id" FROM "order_payments"
      INNER JOIN "payments" ON "payments"."id" = "order_payments"."payment_id"
      WHERE "payments"."payment_type" = 'hub fee' AND "payments"."payee_type" = 'Market' AND "payments"."payee_id" = "orders"."market_id")

    joins(:delivery, :items).
      where(payment_method: ["credit card", "ach", "paypal"]).
      where("orders.id NOT IN (#{subselect})").
      where("deliveries.deliver_on < ?", 48.hours.ago).
      where("orders.placed_at > ?", 6.months.ago).
      where(market_id: automate_market_ids).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      order(:order_number).
      select("orders.*").
      group("orders.id")
  end

  def self.for_sort(order)
    column, direction = column_and_direction(order)
    case column
    when "owed"
      order_by_owed(direction)
    when "date"
      order_by_placed_at(direction)
    when "buyer"
      order_by_buyer(direction)
    when "seller"
      order_by_seller(direction)
    when "delivery_status"
      order_by_delivery_status(direction)
    else
      order_by_order_number(direction)
    end
  end

  def self.orders_for_buyer(user)
    if user.admin?
      all
    elsif user.market_manager?
      select("orders.*").
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = orders.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select("orders.*").joins("INNER JOIN user_organizations ON user_organizations.organization_id = orders.organization_id").
        where("user_organizations.user_id = ?", user.id)
    end
  end

  def self.orders_for_seller(user)
    if user.admin?
      all
    elsif user.market_manager?
      joins(:products).
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id).
      uniq
    else
      joins(:products).
      joins("LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id").
      where("user_organizations.user_id = :user_id", user_id: user.id).
      uniq
    end
  end

  def self.undelivered_orders_for_seller(user)
    scope = orders_for_seller(user)
    scope = scope.joins(:order_items) if user.admin?
    scope.where(order_items: {delivery_status: "pending"})
  end

  def self.create_from_cart(params, cart, buyer)
    billing = cart.organization.locations.default_billing
    order_number = OrderNumber.new(cart.market)

    order = Order.new(
      placed_by: buyer,
      order_number: order_number.id,
      organization: cart.organization,
      market: cart.market,
      delivery: cart.delivery,
      billing_organization_name: cart.organization.name,
      billing_address: billing.address,
      billing_city: billing.city,
      billing_state: billing.state,
      billing_zip: billing.zip,
      billing_phone: billing.phone,
      payment_status: "unpaid",
      payment_method: params[:payment_method],
      delivery_fees: cart.delivery_fees,
      total_cost: cart.total,
      placed_at: DateTime.current
    )

    order.payment_note = params[:payment_note] if params[:payment_note]

    address = cart.delivery.delivery_schedule.buyer_pickup? ?
      cart.delivery.delivery_schedule.buyer_pickup_location : cart.location

    order.apply_delivery_address(address)

    ActiveRecord::Base.transaction do
      cart.items.each do |item|
        order.items << OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item: item, deliver_on_date: cart.delivery.deliver_on)
      end

      raise ActiveRecord::Rollback unless order.save
    end

    order
  end

  def delivered_at
    items.maximum(:delivered_at) if self.delivered?
  end

  def invoice
    self.invoiced_at      = Time.current
    self.invoice_due_date = market.po_payment_term.days.from_now(invoiced_at)
  end

  def invoiced?
    invoiced_at.present?
  end

  def paid_seller_ids
    @paid_seller_ids ||= payments.where(payee_type: "Organization").pluck(:payee_id)
  end

  def sellers
    items.map {|item| item.seller }.uniq
  end

  def subtotal
    items.inject(0) {|sum, item| sum + item.gross_total }
  end

  # Market payable calculations

  def market_payable?
    return false unless delivery_status == "delivered"

    market_payments = payments.select {|p| p.status != "failed" && p.payee == o.market }
    market_payments.sum {|p| p.amount } != payable_to_market
  end

  def payable_to_market
    @payable_to_market ||= payable_subtotal - market_payable_local_orbit_fee - market_payable_payment_fee
  end

  def payable_subtotal
    @payable_subtotal ||= items.to_a.inject(delivery_fees) {|sum, item| sum + (item.delivered? ? item.gross_total : 0) }
  end

  def market_payable_market_fee
    @market_payable_market_fee ||= items.to_a.sum {|i| i.delivered? ? i.market_seller_fee : 0 }
  end

  def market_payable_local_orbit_fee
    @market_payable_local_orbit_fee ||= items.to_a.sum {|i| i.delivered? ? i.local_orbit_seller_fee + i.local_orbit_market_fee : 0 }
  end

  def market_payable_payment_fee
    @market_payable_payment_fee ||= items.to_a.sum {|i| i.delivered? ? i.payment_seller_fee + i.payment_market_fee : 0 }
  end

  def apply_delivery_address(address)
    self.delivery_address = address.address
    self.delivery_city    = address.city
    self.delivery_state   = address.state
    self.delivery_zip     = address.zip
    self.delivery_phone   = address.phone
  end

  private

  def update_paid_at
    if changes[:payment_status] && changes[:payment_status][1] == "paid"
      self.paid_at = Time.current
    end
  end

  def update_total_cost
    cost = items.inject(0) {|sum, item| sum + item.gross_total }
    fees = delivery.delivery_schedule.fees_for_amount(cost)

    cost += fees if cost > 0.0

    update_columns(total_cost: cost, delivery_fees: fees)
  end

  def self.order_by_order_number(direction)
    direction == "asc" ? order("order_number asc") : order("order_number desc")
  end

  def self.order_by_buyer(direction)
    direction == "asc" ? order("payment_status asc") : order("payment_status desc")
  end

  def self.order_by_owed(direction)
    # FIXME: need to sort by amount owed
    direction == "asc" ? order(:id) : order(:id)
  end

  def self.order_by_seller(direction)
    # FIXME: need to sort by the seller paid status
    direction == "asc" ? order(:id) : order(:id)
  end

  def self.order_by_delivery_status
    # FIXME: need to sort by order-wide delivery status
    direction == "asc" ? order(:id) : order(:id)
  end

  def self.order_by_placed_at(direction)
    direction == "asc" ? order("placed_at asc") : order("placed_at desc")
  end
end
