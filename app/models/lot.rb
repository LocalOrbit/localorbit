class Lot < ActiveRecord::Base
  belongs_to :product

  validates :quantity, presence: true
  validates :number, presence: {message: "can't be blank when 'Expiration Date' is present"}, if: lambda { |obj| obj.expires_at.present? }
  validate :expires_at_is_in_future
  validate :good_from_before_expires_at

  private

  def expires_at_is_in_future
    return if expires_at.nil?

    if persisted?
      errors.add(:expires_at, "must be after #{created_at.strftime("%m/%d/%Y")}") if expires_at <= created_at
    else
      errors.add(:expires_at, "must be in the future") if expires_at.past?
    end
  end

  def good_from_before_expires_at
    if good_from && expires_at && good_from > expires_at
      errors.add(:good_from, "cannot be after expires at date")
    end
  end
end

