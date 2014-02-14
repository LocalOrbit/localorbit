class Lot < ActiveRecord::Base
  belongs_to :product

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :number, presence: {message: "can't be blank when 'Expiration Date' is present"}, if: lambda { |obj| obj.expires_at.present? }
  validate :expires_at_is_in_future
  validate :good_from_before_expires_at

  scope :available, lambda { where('good_from IS NULL OR good_from < ?', Time.current).where('expires_at IS NULL OR expires_at > ?', Time.current) }

  def available?
    (expires_at.nil? || expires_at.future?) && (good_from.nil? || good_from.past?)
  end

  def available_quantity
    available? ? quantity : 0
  end

  def simple?
    number.nil? && good_from.nil? && expires_at.nil?
  end

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

