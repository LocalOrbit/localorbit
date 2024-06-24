class Order < ActiveRecord::Base
  include SoftDelete
  include DeliveryStatus
  include Sortable

  INVOICE_STATUSES = %w(due overdue).freeze

  DELIVERY_STATUSES = {
      "pending" => "Pending",
      "delivered" => "Delivered"
  }.freeze

  PAYMENT_STATUSES = {
      "unpaid" => "Unpaid",
      "paid" => "Paid",
      "exported" => "Exported to QBO"
  }.freeze

  BATCH_PO_ACTIONS = {
      "receipt" => "Generate Receipts",
      "export" => "Export",
      "unclose" => "Unclose"
  }.freeze

  BATCH_SO_ACTIONS = {
      "export" => "Export",
      "unclose" => "Unclose",
      "pick_list" => "Pick List",
      "invoice" => "Invoice"
  }.freeze

  paginates_per 50

  before_save :update_paid_at
  before_save :update_payment_status
  before_save :cache_delivery_status
  before_create :set_market_fee_pct
  before_update :update_market_fee_pct
  before_update :update_order_item_payment_status
  before_update :update_total_cost

  audited allow_mass_assignment: true
  has_associated_audits

  dragonfly_accessor :invoice_pdf
  dragonfly_accessor :receipt_pdf

  attr_accessor :credit_card, :bank_account

  belongs_to :market, inverse_of: :orders
  belongs_to :organization, inverse_of: :orders
  belongs_to :delivery, inverse_of: :orders
  belongs_to :placed_by, class_name: User
  belongs_to :discount

  has_many :items, inverse_of: :order, class_name: OrderItem, autosave: true, dependent: :destroy do
    def for_checkout
      eager_load(product: [:organization, :prices]).order("organizations.name, products.name").group_by do |item|
        item.product.organization.name
      end
    end
  end


  has_many :cross_selling_lists, through: :market, foreign_key: :entity_id
  has_many :cross_selling_list_products, through: :cross_selling_lists
  has_many :cross_sold_products, through: :cross_selling_list_products, source: :product

  has_many :order_payments, inverse_of: :order
  has_many :payments, through: :order_payments, inverse_of: :orders
  has_many :products, through: :items
  has_many :sellers, through: :products, class_name: Organization
  has_many :delivery_notes
  has_one :credit, -> {visible}, autosave: false

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
  #validates :order_number, presence: true
  validates :organization_id, presence: true
  validates :payment_method, presence: true, inclusion: {in: Payment::PAYMENT_METHODS_CHECK.keys, allow_blank: true}
  validates :payment_status, presence: true
  validates :placed_at, presence: true
  validates :total_cost, presence: true

  scope :recent, -> { visible.order("created_at DESC").limit(15) }
  scope :upcoming_delivery, -> { visible.joins(:delivery).where("deliveries.deliver_on > ?", Time.current.end_of_minute) }
  scope :upcoming_buyer_delivery, -> { visible.joins(:delivery).where("deliveries.buyer_deliver_on > ?", Time.current.end_of_minute) }
  scope :uninvoiced, -> { visible.purchase_orders.where(invoiced_at: nil) }
  scope :invoiced, -> { visible.purchase_orders.where.not(invoiced_at: nil) }
  scope :unpaid, -> { visible.where(payment_status: "unpaid") }
  scope :paid, -> { visible.where(payment_status: "paid") }
  scope :delivered, -> { visible.where("order_items.delivery_status = ?", "delivered").group("orders.id") }
  scope :undelivered, -> { visible.where("order_items.delivery_status = ?", "pending").group("orders.id") }
  scope :paid_with, lambda {|method| visible.where(payment_method: method) }
  scope :purchase_orders, -> { where(payment_method: "purchase order") }
  scope :payment_overdue, -> { unpaid.where("invoice_due_date < ?", (Time.current - 1.day).end_of_day) }
  scope :payment_due, -> { unpaid.where("invoice_due_date >= ?", (Time.current - 1.day).end_of_day) }
  scope :paid_between, lambda {|range| paid.where(paid_at: range) }
  scope :due_between, lambda {|range| invoiced.where(invoice_due_date: range) }
  scope :clean_payment_records, -> { where(arel_table[:placed_at].gt(Time.parse("2014-01-01"))) }
  scope :for_seller, -> (user) { orders_for_seller(user) }
  scope :on_automate_plan, -> { joins(market: [organization: :plan]).where(plans: {name: 'Automate'}) }
  scope :not_on_automate_plan, -> { joins(market: [organization: :plan]).where.not(plans: {name: 'Automate'}) }
  scope :so_orders, -> { where(order_type: 'sales')}
  scope :po_orders, -> { where(order_type: 'purchase')}

  scope :stripe,       -> { where(payment_provider: PaymentProvider::Stripe.id.to_s) }
  scope :not_stripe,   -> { where.not(payment_provider: PaymentProvider::Stripe.id.to_s) }

  scope :po, -> {visible.where(order_type: "purchase")}
  scope :sold_through, -> {visible.where(sold_through: true)}
  scope :not_sold_through, -> {visible.where("sold_through IS NULL OR sold_through IS false")}

  scope :placed_between, lambda {|range| visible.where(placed_at: range) }

  scope_accessible :sort, method: :for_sort, ignore_blank: true
  scope_accessible :payment_status

  accepts_nested_attributes_for :items, allow_destroy: true

  def self.delivered_between(range)
    delivered.
      having("MAX(order_items.delivered_at) >= ?", range.begin).
      having("MAX(order_items.delivered_at) < ?", range.end)
  end

  def order_number
    if market.number_format_numeric.nil? || market.number_format_numeric == 0 # segmented, e.g. not numeric
      self[:order_number]
    else
      self[:id].to_s
    end
  end

  def self.fully_delivered
    joins(:items).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      group("orders.id")
  end

  def self.not_paid_for(payment_type, type=:payee)
    where.not(id: OrderPayment.market_paid_orders_subselect(payment_type, type))
  end

  def self.payable(current_time:nil)
    # This is a slightly fuzzy match right now.
    # TODO: Implement delivery_end on deliveries for greater accuracy
    buyer_deliver_on = Delivery.arel_table[:buyer_deliver_on]
    joins(:delivery).where(buyer_deliver_on.not_eq(nil))
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

  def self.payments_to_sellers_subselect
    %|SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = 'Organization' AND payments.payee_id = products.organization_id|
  end

  def self.with_payments_made_to_sellers
    joins(items: :product).
    where("EXISTS(#{payments_to_sellers_subselect})")
  end

  def self.without_payments_made_to_sellers
    joins(items: :product).
    where("NOT EXISTS(#{payments_to_sellers_subselect})")
  end

  def self.payable_to_sellers(current_time:Time.current.end_of_minute, seller_organization_id:nil)
    res = select("orders.*, products.organization_id as seller_id").
      fully_delivered.
      payable(current_time: current_time).
      without_payments_made_to_sellers.
      group("seller_id").
      order(:order_number).
      includes(:market)

    if seller_organization_id.present?
      res = res.where(products: { organization_id: seller_organization_id })
    end

    res
  end

  # Ransacker to convert ID to a string to search in orders with numeric order numbers using _cont
  ransacker :id do
    Arel.sql("to_char(orders.id, '9999999')")
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
      # where(buyer_orders_arel(user).or(manager_orders_arel(user))).uniq #.where(market_id: user.markets)
      where(buyer_orders_arel(user).or(manager_orders_arel(user))).uniq.where(market_id: user.markets)
    end
  end

  def self.orders_for_consignment_seller(user)
    if user.admin?
      all
    else
      # TODO: check cross selling logic
      #joins(:products).where(seller_orders_arel(user).or(manager_orders_arel(user)).or(cross_sold_products_arel(user))).uniq
      includes(:products).where(seller_orders_arel(user).or(manager_orders_arel(user))).uniq
    end
  end

  def self.orders_for_seller(user)
    if user.admin?
      all
    else
      # TODO: check cross selling logic
      #joins(:products).where(seller_orders_arel(user).or(manager_orders_arel(user)).or(cross_sold_products_arel(user))).uniq
      joins(:products).where(seller_orders_arel(user).or(manager_orders_arel(user))).uniq
    end
  end

  def self.user_markets(user)
    arel_table[:market_id].in(user.markets)
  end

  def self.cross_selling_markets(user)
    # KXM cross_selling_markets not yet implemented... is it needed?
    # The code below is the same as user_markets (above)
    arel_table[:market_id].in(user.markets)
  end

  def self.undelivered_orders_for_seller(user)
    scope = orders_for_seller(user)
    scope = scope.joins(:order_items) if user.admin?
    scope.where(order_items: {delivery_status: "pending"})
  end

  def self.buyer_orders_arel(user)
    arel_table[:organization_id].in(UserOrganization.where(user_id: [user.id]).select(:organization_id).arel)
  end

  def self.seller_orders_arel(user)
    Product.arel_table[:organization_id].in(UserOrganization.where(user_id: [user.id]).select(:organization_id).arel)
  end

  def self.manager_orders_arel(user)
    arel_table[:market_id].in(ManagedMarket.where(user_id: [user.id]).select(:market_id).arel)
  end

  def self.cross_sold_products_arel(user)
    Product.arel_table[:id].in(CrossSellingListProduct.joins(:cross_selling_list).where("cross_selling_lists.deleted_at IS NULL AND cross_selling_lists.status = 'Published' AND cross_selling_lists.entity_type = 'Market' AND cross_selling_lists.creator = ? AND cross_selling_lists.entity_id IN (?)", true, user.markets.pluck(:id)).select(:product_id).arel)
  end

  def add_cart_items(cart_items, deliver_on)
    cart_items.each do |cart_item|
      add_cart_item(cart_item, deliver_on)
    end
  end

  def add_cart_item(cart_item, deliver_on)
    category_fee_pct = cart_item.fee == 1 ? cart_item.product.category.level_fee(self.market.id) : 0
    items << OrderItem.create_with_order_and_item_and_deliver_on_date(self, cart_item, deliver_on, category_fee_pct)
  end

  def delivered_at
    items.maximum(:delivered_at) if self.delivered?
  end

  def discount_code
    discount.try(:code)
  end

  def discount_amount
    items.sum(:discount_market) + items.sum(:discount_seller)
  end

  def invoice
    self.invoiced_at      = Time.current
    self.invoice_due_date = market.po_payment_term.days.from_now(invoiced_at)
  end

  def uninvoice
    self.invoiced_at      = nil
    self.invoice_due_date = nil
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
    sellers = []

    if uuid
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").map do |audit|
        if audit.audited_changes["quantity"] && audit.audited_changes["quantity"].second >0 && audit.action != "destroy"
          # If auditable is there, use the seller, or else find it from the product in the changes
          sellers << audit.try(:auditable).try(:seller) || Product.find_by(id: audit.audited_changes["product_id"]).try(:organization)
        end
      end
    end
    sellers.compact.uniq
  end

  def sellers_with_cancel
    uuid = audits.last.try(:request_uuid)

    sellers = []
    if uuid
      Audit.where(request_uuid: uuid, auditable_type: "OrderItem").map do |audit|
        if (audit.audited_changes["quantity"] && audit.audited_changes["quantity"].second == 0)
          # If auditable is there, use the seller, or else find it from the product in the changes
          sellers << audit.try(:auditable).try(:seller) || Product.find_by(id: audit.audited_changes["product_id"]).try(:organization)
        end
      end
    end
    sellers.compact.uniq
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

  def payable_lo_fees
    delivery_fees * (market.local_orbit_seller_fee + market.local_orbit_market_fee) / 100 +
      items.each.sum {|i| i.local_orbit_seller_fee + i.local_orbit_market_fee }
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

  def usable_items
    items.reject {|i| i.destroyed? || i.marked_for_destruction? }
  end

  def gross_total
    # binding.pry
    usable_items.sum(&:gross_total)
  end

  def credit_amount
    if credit && credit.valid?
      credit.calculated_amount
    else
      0
    end
  end

  def is_localeyes_order?
    market.organization.plan.has_procurement_managers
  end

  def update_total_cost
    cost = gross_total
    if credit && credit.apply_to == "subtotal"
      cost = gross_total - credit_amount
    end
    if market.is_buysell_market?
      self.delivery_fees = calculate_delivery_fees(cost).round(2) unless delivery_fees == 0
    end
    self.total_cost    = calculate_total_cost(cost).round(2)
  end

  def mark_as_unpaid
    update_attributes(payment_status: 'unpaid', paid_at: nil)
    items.each do |oi|
      oi.payment_status = "unpaid"
    end
    save!
  end

  def sales_order?
    order_type == 'sales'
  end

  def purchase_order?
    order_type == 'purchase'
  end

  private

  def update_paid_at
    self.paid_at ||= Time.current if payment_status == "paid"
  end

  def set_market_fee_pct
    self.market_seller_fee_pct = market.market_seller_fee
  end

  def update_market_fee_pct
    if self.market_seller_fee_pct.nil?
      self.market_seller_fee_pct = market.market_seller_fee
    end
  end

  def update_payment_status
    statuses = items.map(&:payment_status).uniq
    self.payment_status = "refunded" if statuses == ["refunded"]
    self.payment_status = "exported" if !qb_ref_id.nil?
  end

  def update_order_item_payment_status
    return unless payment_status_changed?
    items.where(payment_status: ["pending", "unpaid"]).update_all(payment_status: payment_status)
  end

  def calculate_delivery_fees(gross)
    if gross > 0.0
      delivery.delivery_schedule.fees_for_amount(gross)
    else
      0
    end
  end

  def calculate_total_cost(gross)
    if gross > 0.0
      if credit && credit.apply_to == "subtotal"
        gross + delivery_fees - discount_amount
      else
        gross + delivery_fees - discount_amount - credit_amount
      end
    else
      0
    end
  end
end
