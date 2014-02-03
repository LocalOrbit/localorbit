class Lot < ActiveRecord::Base
  belongs_to :product

  validates :quantity, presence: true
  validates :number, presence: {message: "can't be blank when 'Expiration Date' is present"}, if: lambda { |obj| obj.expires_at.present? }
  validate :expires_at_is_in_future
  validate :good_from_before_expires_at

  private
  def expires_at_is_in_future
    return if self.expires_at.nil?

    if !self.persisted?
      errors.add(:expires_at, "must be in the future") if self.expires_at.past?
    else
      errors.add(:expires_at, "must be after this lot was created") if self.expires_at <=  self.created_at
    end
  end

  def good_from_before_expires_at
    if self.good_from && self.expires_at
      errors.add(:good_from, "cannot be after 'expires at'") if self.good_from > self.expires_at
    end
  end
end

