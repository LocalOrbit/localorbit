class Payment < ActiveRecord::Base
  audited allow_mass_assignment: true

  PAYMENT_TYPES = {
    "hub fee" => "Market Fee",
    "lo fee" => "LO Fee",
    "market payment" => "Market Payment",
    "order" => "Order",
    "order refund" => "Order Refund",
    "seller payment" => "Seller Payment",
    "service" => "Service Fee",
    "service refund" => "Service Refund"
  }.freeze

  PAYMENT_METHODS = {
    "ach" => "ACH",
    "cash" => "Cash",
    "check" => "Check",
    "credit card" => "Credit Card",
    "purchase order" => "Purchase Order"
  }.freeze

  belongs_to :payee, polymorphic: true
  belongs_to :payer, polymorphic: true
  belongs_to :market
  belongs_to :bank_account
  belongs_to :parent, class_name: "Payment"

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

  validates :amount, presence: true, numericality: true
  validate :payee_or_payer_is_set

  scope :successful, -> { where(status: %w(paid pending)) }
  scope :not_refunded, -> { where(arel_table[:amount].gt(arel_table[:refunded_amount])) }
  scope :refundable, -> { successful.not_refunded.where(payment_type: "order") }
  scope :buyer_payments, -> { where(payment_type: ["order", "order refund"]) }
  scope :for_orders, lambda {|orders| joins(:order_payments).where(order_payments: {order_id: orders}) }
  scope :seller_payments, -> { where(payment_type: "seller payment") }
  scope :made_after, ->(start_at) { where(arel_table[:created_at].gt(start_at)) }

  ransacker :update_at_date do |_|
    Arel::Nodes::NamedFunction.new("DATE", [arel_table[:updated_at]])
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

  def refund?
    ["order refund", "service refund"].include? payment_type
  end

  private

  def payee_or_payer_is_set
    if payee_id.nil? && payer_id.nil?
      errors.add(:base, "A Payee or Payer must be specified")
    end
  end
end
