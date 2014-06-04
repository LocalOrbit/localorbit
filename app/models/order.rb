class Order < ActiveRecord::Base
  INVOICE_STATUSES = [
    "due",
    "overdue"
  ].freeze

  include DeliveryStatus
  include Sortable

  attr_accessor :credit_card, :bank_account

  belongs_to :market
  belongs_to :organization
  belongs_to :delivery
  belongs_to :placed_by, class: User

  has_many :items, inverse_of: :order, class: OrderItem, autosave: true, dependent: :destroy
  has_many :order_payments, inverse_of: :order
  has_many :payments, through: :order_payments, inverse_of: :orders

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

  validate :validate_items

  before_save :update_paid_at
  before_save :update_total_cost

  scope :recent, -> { order("created_at DESC").limit(15) }
  scope :upcoming_delivery, -> { joins(:delivery).where("deliveries.deliver_on > ?", Time.current) }
  scope :uninvoiced, -> { where(payment_method: "purchase order", invoiced_at: nil) }
  scope :invoiced, -> { where(payment_method: "purchase order").where.not(invoiced_at: nil) }
  scope :unpaid, -> { where(payment_status: "unpaid") }
  scope :paid, -> { where(payment_status: "paid") }
  scope :delivered, -> { where("order_items.delivery_status = ?", "delivered").group('orders.id') }
  scope :paid_with, lambda { |method| where(payment_method: method) }
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
    delivered
      .having("MAX(order_items.delivered_at) >= ?", range.begin)
      .having("MAX(order_items.delivered_at) < ?", range.end)
  }
  scope :paid_between, lambda { |range| paid.where(paid_at: range) }
  scope :due_between, lambda { |range| invoiced.where(invoice_due_date: range) }

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :payment_status

  accepts_nested_attributes_for :items

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
      select("DISTINCT orders.*").
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id
             LEFT JOIN managed_markets ON managed_markets.market_id = orders.market_id").
      where("user_organizations.user_id = :user_id OR managed_markets.user_id = :user_id", user_id: user.id)
    else
      select("DISTINCT orders.*").
      joins("INNER JOIN order_items ON order_items.order_id = orders.id
             INNER JOIN products ON products.id = order_items.product_id
             LEFT JOIN user_organizations ON user_organizations.organization_id = products.organization_id").
      where("user_organizations.user_id = :user_id", user_id: user.id)
    end
  end

  def self.undelivered_orders_for_seller(user)
    scope = orders_for_seller(user)
    scope = scope.joins(:order_items) if user.admin?
    scope.where(order_items: {delivery_status: "pending"})
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

    order.delivery_address = address.address
    order.delivery_city    = address.city
    order.delivery_state   = address.state
    order.delivery_zip     = address.zip
    order.delivery_phone   = address.phone

    ActiveRecord::Base.transaction do
      cart.items.each do |item|
        order.items << OrderItem.create_with_order_and_item_and_deliver_on_date(order: order, item: item, deliver_on_date: cart.delivery.deliver_on)
      end

      raise ActiveRecord::Rollback unless order.save
    end

    order
  end

  def self.joining_products
    joins(items: :product).includes(:items).group("orders.id").order("organization_id DESC")
  end

  def self.order_items_by_product
    joining_products.map {|order| order.items }.flatten.group_by(&:product)
  end

  def self.order_items_by_product_for_organization(organization)
    joining_products.where(products: {organization_id: organization.id}).
      map(&:items).flatten.group_by(&:product)
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
    @paid_seller_ids ||= payments.where(payee_type: 'Organization').pluck(:payee_id)
  end

  def sellers
    items.map {|item| item.seller }.uniq
  end

  def subtotal
    items.inject(0) {|sum, item| sum + item.gross_total}
  end

  private

  def validate_items
    if items.empty?
      errors.add(:items, "cannot be empty")
    end
  end

  def update_paid_at
    if changes[:payment_status] && changes[:payment_status][1] == "paid"
      self.paid_at = Time.current
    end
  end

  def update_total_cost
    self.total_cost = items.inject(0) {|sum, item| sum = sum + item.gross_total }
    self.delivery_fees = delivery.delivery_schedule.fees_for_amount(self.total_cost)
    
    self.total_cost += self.delivery_fees
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

  def self.order_by_placed_at(direction)
    direction == "asc" ? order("placed_at asc") : order("placed_at desc")
  end
end
