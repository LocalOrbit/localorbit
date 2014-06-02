class Payment < ActiveRecord::Base
  PAYMENT_TYPES = {
    "delivery fee" => "Delivery Fee",
    "order" => "Order",
    "service" => "Service Fee"
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

  # Add organization-specifc payer and payee associations so we can
  # search payments by payer and payee attributes.
  belongs_to :organization_payer,
    -> { where(payments: { payer_type: "Organization" }) },
    class_name: "Organization",
    foreign_key: "payer_id"
  belongs_to :organization_payee,
    -> { where(payments: { payee_type: "Organization" }) },
    class_name: "Organization",
    foreign_key: "payee_id"

  belongs_to :from_organization, class_name: "Organization", foreign_key: :payer_id
  belongs_to :from_market, class_name: "Market", foreign_key: :payer_id

  has_many :order_payments, inverse_of: :payment
  has_many :orders, through: :order_payments, inverse_of: :payments

  scope :successful, -> { where(status: ['paid', 'pending'])}
  scope :refundable, -> { successful.where("amount > refunded_amount") }

  def bank_account
    BankAccount.find_by(balanced_uri: balanced_uri)
  end

  ransacker :update_at_date do |parent|
    Arel.sql("DATE(updated_at)")
  end

  ransacker :payer_type_id do |parent|
    Arel.sql("NULLIF(payer_type || payer_id, '')")
  end

  ransacker :payee_type_id do |parent|
    Arel.sql("NULLIF(payee_type || payee_id, '')")
  end

  def unrefunded_amount
    amount - refunded_amount
  end

  def balanced_debit
    Balanced::Debit.find(balanced_uri) if balanced_uri.present?
  end
end
