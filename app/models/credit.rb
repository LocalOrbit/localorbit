class Credit < ActiveRecord::Base
  belongs_to :order, autosave: false
  belongs_to :user
  after_save :update_order
  PERCENTAGE = "percentage"
  FIXED = "fixed"

  validates :order, :user, :percentage_or_fixed, :amount, presence: true
  validates :percentage_or_fixed, inclusion: {in: [PERCENTAGE, FIXED], message: "Not a valid credit type."}
  validates :amount, numericality: {greater_than_or_equal_to: 0}
  validate :amount_cannot_exceed_gross_total, :order_must_be_paid_by_po

  def calculated_amount
    total = order.gross_total
    if percentage_or_fixed == Credit::PERCENTAGE
      (total * amount).round 2
    elsif percentage_or_fixed == Credit::FIXED
      amount.round 2
    end
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
    amount != nil && percentage_or_fixed == Credit::PERCENTAGE && amount > 1
  end

  def fixed_amount_too_high
    amount != nil && order != nil && percentage_or_fixed == Credit::FIXED && amount > order.gross_total
  end
end
