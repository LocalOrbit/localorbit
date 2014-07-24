class Discount < ActiveRecord::Base
  include SoftDelete
  include Sortable

  self.inheritance_column = nil

  belongs_to :market

  enum type: {percentage: 0, fixed: 1}

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :type, presence: true
  validate :starts_before_it_ends
  validate :future_end_date

  private

  def future_end_date
    errors.add(:end_date, "must be in the future") if end_date && (!persisted? || end_date_changed?) && end_date < Time.current
  end

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
