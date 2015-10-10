class Credit < ActiveRecord::Base
  belongs_to :order, autosave: false
  belongs_to :user
  belongs_to :paying_org, class: Organization
  after_save :update_order

  PERCENTAGE = "percentage"
  FIXED = "fixed"
  MARKET = "market"
  ORGANIZATION = "organization"

  AMOUNT_TYPES = [PERCENTAGE, FIXED]
  PAYER_TYPES = [MARKET, ORGANIZATION]

  validates :order, :user, :amount_type, :amount, presence: true
  validates :amount_type, inclusion: {in: AMOUNT_TYPES, message: "Not a valid credit type."}
  validates :payer_type, inclusion: {in: PAYER_TYPES, message: "Not a valid payer type."}
  validates :amount, numericality: {greater_than_or_equal_to: 0}
  validate :amount_cannot_exceed_gross_total, :order_must_be_paid_by_po

  def calculated_amount
    if amount_type == Credit::PERCENTAGE
      total = order.gross_total
      (total * (amount / 100)).round 2
    elsif amount_type == Credit::FIXED
      amount
    end
  end

  def amount=(value)
    write_attribute(:amount, value && value.to_f.round(2))
  end

  private

  def amount_cannot_exceed_gross_total
    if percentage_amount_too_high || fixed_amount_too_high
      errors.add(:amount, "can't exceed the order's gross total")
    end
  end

  def order_must_be_paid_by_po
    if(order && order.payment_method != "purchase order")
      errors.add(:order, "must be paid for by purchase order")
    end
  end

  def update_order
    order.save
  end

  def percentage_amount_too_high
    amount != nil && amount_type == Credit::PERCENTAGE && amount > 100
  end

  def fixed_amount_too_high
    amount != nil && order != nil && amount_type == Credit::FIXED && amount > order.gross_total
  end
end
