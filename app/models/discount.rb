class Discount < ActiveRecord::Base
  enum type: {percentage: 0, fixed: 1}

  validates :name, presence: true
  validates :code, presence: true
  validates :type, presence: true
  validate :starts_before_it_ends

  private

  def starts_before_it_ends
    if end_date.present?
      if start_date.present?
        errors.add(:end_date, "must be after start date") if end_date <= start_date
      else
        errors.add(:end_date, "must have a start date")
      end
    end
  end
end
