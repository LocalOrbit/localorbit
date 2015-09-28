class Credit < ActiveRecord::Base
  belongs_to :order, autosave: false
  belongs_to :user
  after_save :update_order
  PERCENTAGE = "percentage"
  FIXED = "fixed"

  validates :order, :user, :percentage_or_fixed, :amount, presence: true
  validates :percentage_or_fixed, inclusion: {in: [PERCENTAGE, FIXED], message: "Not a valid credit type."}

  def calculated_amount
    total = order.gross_total
    if percentage_or_fixed == Credit::PERCENTAGE
      (total * amount).round 2
    elsif percentage_or_fixed == Credit::FIXED
      amount.round 2
    end
  end

  private

  def update_order
    order.save
  end
end
