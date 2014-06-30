class Payment < ActiveRecord::Base
  PAYMENT_TYPES = {
    "delivery fee" => "Delivery Fee",
    "hub fee" => "Market Fee",
    "lo fee" => "LO Fee",
    "market payment" => "Market Payment",
    "order" => "Order",
    "order refund" => "Order Refund",
    "seller payment" => "Seller Payment",
    "service" => "Service Fee"
  }.freeze

  PAYMENT_METHODS = {
    "ach" => "ACH",
    "cash" => "Cash",
    "check" => "Check",
    "credit card" => "Credit Card",
    "paypal" => "PayPal",
    "purchase order" => "Purchase Order"
  }.freeze

  belongs_to :payee, polymorphic: true
  belongs_to :payer, polymorphic: true
  belongs_to :market
  belongs_to :bank_account

  # Add organization-specifc payer and payee associations so we can
  # search payments by payer and payee attributes.
  belongs_to :organization_payer,
             -> { where(payments: {payer_type: "Organization"}) },
             class_name: "Organization",
             foreign_key: "payer_id"
  belongs_to :organization_payee,
             -> { where(payments: {payee_type: "Organization"}) },
             class_name: "Organization",
             foreign_key: "payee_id"

  belongs_to :from_organization, class_name: "Organization", foreign_key: :payer_id
  belongs_to :from_market, class_name: "Market", foreign_key: :payer_id

  has_many :order_payments, inverse_of: :payment
  has_many :orders, through: :order_payments, inverse_of: :payments

  scope :successful, -> { where(status: %w(paid pending)) }
  scope :refundable, -> { successful.where(payment_type: "order").where("amount > refunded_amount") }
  scope :buyer_payments, -> { where(payment_type: ["order", "order refund"]) }
  scope :for_orders, lambda {|orders| joins(:order_payments).where(order_payments: {order_id: orders}) }

  def self.payments_for_user(user)
    subselect = "SELECT 1 FROM payments
      INNER JOIN order_payments ON order_payments.order_id = orders.id AND order_payments.payment_id = payments.id
      WHERE payments.payee_type = ? AND payments.payee_id = products.organization_id"

    Order.select("orders.*, products.organization_id as seller_id").joins(:delivery, items: :product).
      where("NOT EXISTS(#{subselect})", "Organization").
      # This is a slightly fuzzy match right now.
      # TODO: Implement delivery_end on deliveries for greater accuracy
      where("deliveries.deliver_on < ?", 48.hours.ago).
      having("BOOL_AND(order_items.delivery_status IN (?)) AND BOOL_OR(order_items.delivery_status = ?)", ["delivered", "canceled"], "delivered").
      group("orders.id, seller_id").
      order("orders.order_number").
      includes(:market)
  end

  ransacker :update_at_date do |_|
    Arel.sql("DATE(updated_at)")
  end

  ransacker :payer_type_id do |_|
    Arel.sql("NULLIF(payer_type || payer_id, '')")
  end

  ransacker :payee_type_id do |_|
    Arel.sql("NULLIF(payee_type || payee_id, '')")
  end

  def unrefunded_amount
    amount - refunded_amount
  end

  def balanced_transaction
    # Will return the appropriate transaction type for any transaction
    Balanced::Transaction.find(balanced_uri) if balanced_uri.present?
  end
end
