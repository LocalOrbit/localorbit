class Order < ActiveRecord::Base
  include SoftDelete
  include DeliveryStatus
  include Sortable

  INVOICE_STATUSES = %w(due overdue).freeze

  before_save :update_paid_at
  before_save :update_payment_status
  before_update :update_order_item_payment_status
  before_update :update_total_cost

  audited allow_mass_assignment: true
  has_associated_audits

  attr_accessor :credit_card, :bank_account

  belongs_to :market, inverse_of: :orders
  belongs_to :organization, inverse_of: :orders
  belongs_to :delivery, inverse_of: :orders
  belongs_to :placed_by, class: User
  belongs_to :discount

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

  scope :recent, -> { visible.order("created_at DESC").limit(15) }
  scope :upcoming_delivery, -> { visible.joins(:delivery).where("deliveries.deliver_on > ?", Time.current) }
  scope :uninvoiced, -> { visible.purchase_orders.where(invoiced_at: nil) }
  scope :invoiced, -> { visible.purchase_orders.where.not(invoiced_at: nil) }
  scope :unpaid, -> { visible.where(payment_status: "unpaid") }
  scope :paid, -> { visible.where(payment_status: "paid") }
  scope :delivered, -> { visible.where("order_items.delivery_status = ?", "delivered").group("orders.id") }
  scope :paid_with, lambda {|method| visible.where(payment_method: method) }
  scope :purchase_orders, -> { where(payment_method: "purchase order") }
  scope :payment_overdue, -> { unpaid.where("invoice_due_date < ?", (Time.current - 1.day).end_of_day) }
  scope :payment_due, -> { unpaid.where("invoice_due_date >= ?", (Time.current - 1.day).end_of_day) }
  scope :paid_between, lambda {|range| paid.where(paid_at: range) }
  scope :due_between, lambda {|range| invoiced.where(invoice_due_date: range) }

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :payment_status

  accepts_nested_attributes_for :items, allow_destroy: true

  def self.delivered_between(range)
    delivered.
      having("MAX(order_items.delivered_at) >= ?", range.begin).
      having("MAX(order_items.delivered_at) < ?", range.end)
  end

  def self.fully_delivered
    joins(:items).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      group("orders.id")
  end

  def self.not_paid_for(payment_type)
    where.not(id: OrderPayment.market_paid_orders_subselect(payment_type))
  end

  def self.payable
    # This is a slightly fuzzy match right now.
    # TODO: Implement delivery_end on deliveries for greater accuracy
    joins(:delivery).where("deliveries.deliver_on < ?", 48.hours.ago)
  end

  def self.payment_status(status)
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
  end

  def self.used_lo_payment_processing
    where(payment_method: ["credit card", "ach", "paypal"])
  end

  def self.balanced_payable_to_market
    # TODO: figure out how to make sure the orders haven't changed
    non_automate_market_ids = Market.joins(:plan).where.not(plans: {name: "Automate"}).pluck(:id)

    paid.fully_delivered.used_lo_payment_processing.not_paid_for("market payment").
      where("orders.placed_at > ?", 6.months.ago).
      where(market_id: non_automate_market_ids).
      preload(:items, :market)
  end

  def self.payable_to_sellers
    subselect = "SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = ? AND payments.payee_id = products.organization_id"

    fully_delivered.payable.
      select("orders.*, products.organization_id as seller_id").
      joins(items: :product).
      where("NOT EXISTS(#{subselect})", "Organization").
      group("seller_id"). # orders.id is already present from fully_delivered
      order(:order_number).
      includes(:market)
  end

  def self.payable_lo_fees
    fully_delivered.purchase_orders.payable.not_paid_for("lo fee").order(:order_number)
  end

  def self.payable_market_fees
    # TODO: figure out how to make sure the orders haven't changed
    automate_market_ids = Market.joins(:plan).where(plans: {name: "Automate"}).pluck(:id)

    fully_delivered.used_lo_payment_processing.payable.not_paid_for("hub fee").
      # orders before this were poorly tracked
      where("orders.placed_at > ?", Time.parse("2014-01-01")).
      where(market_id: automate_market_ids).
      order(:order_number)
  end

  def self.arel_column_for_sort(column_name)
    case column_name
    when "owed"
      # FIXME: need to sort by amount owed
      arel_table[:id]
    when "date"
      arel_table[:placed_at]
    when "buyer"
      arel_table[:payment_status]
    when "seller"
      # FIXME: need to sort by the seller paid status
      arel_table[:id]
    when "delivery_status"
      # FIXME: need to sort by order-wide delivery status
      arel_table[:id]
    else
      arel_table[:order_number]
    end
  end

  def self.orders_for_buyer(user)
    if user.admin?
      all
    else
      where(buyer_orders_arel(user).or(manager_orders_arel(user))).uniq
    end
  end

  def self.orders_for_seller(user)
    if user.admin?
      all
    else
      joins(:products).where(seller_orders_arel(user).or(manager_orders_arel(user))).uniq
    end
  end

  def self.undelivered_orders_for_seller(user)
    scope = orders_for_seller(user)
    scope = scope.joins(:order_items) if user.admin?
    scope.where(order_items: {delivery_status: "pending"})
  end

  def self.buyer_orders_arel(user)
    arel_table[:organization_id].in(UserOrganization.where(user_id: user.id).select(:organization_id).arel)
  end

  def self.seller_orders_arel(user)
    Product.arel_table[:organization_id].in(UserOrganization.where(user_id: user.id).select(:organization_id).arel)
  end

  def self.manager_orders_arel(user)
    arel_table[:market_id].in(ManagedMarket.where(user_id: user.id).select(:market_id).arel)
  end

  def add_cart_items(cart_items, deliver_on)
    cart_items.each do |cart_item|
      add_cart_item(cart_item, deliver_on)
    end
  end

  def add_cart_item(cart_item, deliver_on)
    items << OrderItem.create_with_order_and_item_and_deliver_on_date(self, cart_item, deliver_on)
  end

  def delivered_at
    items.maximum(:delivered_at) if self.delivered?
  end

  def discount_code
    discount.try(:code)
  end

  def discount_amount
    @discount_amount ||= items.sum(:discount_market) + items.sum(:discount_seller)
  end

  def invoice
    self.invoiced_at      = Time.current
    self.invoice_due_date = market.po_payment_term.days.from_now(invoiced_at)
  end

  def invoiced?
    invoiced_at.present?
  end

  def paid_seller_ids
    @paid_seller_ids ||= payments.seller_payments.pluck(:payee_id)
  end

  def sellers
    items.map(&:seller).uniq
  end

  def sellers_with_changes
    uuid = audits.last.try(:request_uuid)

    if uuid
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").map do |audit|
        # If auditable is there, use the seller, or else find it from the product in the changes
        audit.try(:auditable).try(:seller) || Product.find_by(id: audit.audited_changes["product_id"]).try(:organization)
      end.reject(&:nil?).uniq
    else
      []
    end
  end

  def subtotal
    @subtotal ||= items.each.sum(&:gross_total)
  end

  # Market payable calculations

  def payable_to_market
    @payable_to_market ||= payable_subtotal - market_payable_local_orbit_fee - market_payable_payment_fee - items.sum(:discount_market)
  end

  def payable_subtotal
    @payable_subtotal ||= delivery_fees + items.delivered.each.sum(&:gross_total)
  end

  def market_payable_market_fee
    @market_payable_market_fee ||= items.delivered.sum(:market_seller_fee)
  end

  def market_payable_local_orbit_fee
    @market_payable_local_orbit_fee ||= items.delivered.sum("local_orbit_seller_fee + local_orbit_market_fee")
  end

  def market_payable_payment_fee
    @market_payable_payment_fee ||= items.delivered.sum("payment_seller_fee + payment_market_fee")
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
    self.paid_at ||= Time.current if payment_status == "paid"
  end

  def update_payment_status
    statuses = items.map(&:payment_status).uniq
    self.payment_status = "refunded" if statuses == ["refunded"]
  end

  def update_order_item_payment_status
    return unless payment_status_changed?
    items.where(payment_status: ["pending", "unpaid"]).update_all(payment_status: payment_status)
  end

  def update_total_cost
    usable_items = items.reject {|i| i.destroyed? || i.marked_for_destruction? }

    cost = usable_items.sum(&:gross_total)

    self.delivery_fees = calculate_delivery_fees(cost)
    self.total_cost    = calculate_total_cost(cost, usable_items)
  end

  def calculate_delivery_fees(gross)
    if gross > 0.0
      delivery.delivery_schedule.fees_for_amount(gross)
    else
      0
    end
  end

  def calculate_total_cost(gross, items)
    if gross > 0.0
      gross + delivery_fees - discount_amount
    else
      0
    end
  end
end
