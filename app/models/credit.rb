class Credit < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  PERCENTAGE = "percentage"
  FIXED = "fixed"

  validates :order, :user, :percentage_or_fixed, :amount, presence: true
  validates :percentage_or_fixed, inclusion: {in: [PERCENTAGE, FIXED], message: "Not a valid credit type."}
end
