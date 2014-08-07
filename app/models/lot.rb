class Lot < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :product, inverse_of: :lots

  validates :quantity, numericality: {greater_than_or_equal_to: 0, less_than: 1_000_000}
  validates :number, presence: {message: "can't be blank when 'Expiration Date' is present"}, if: lambda {|obj| obj.expires_at.present? }
  validates :number, uniqueness: {scope: :product_id, allow_blank: true}
  validate :expires_at_is_in_future
  validate :good_from_before_expires_at

  scope :available, lambda { |time=Time.current|
    where("(lots.good_from IS NULL OR lots.good_from < :time) AND (lots.expires_at IS NULL OR lots.expires_at > :time) AND quantity > 0", time: time)
  }

  def available?(time=Time.current)
    (expires_at.nil? || expires_at > time) && (good_from.nil? || good_from < time)
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
