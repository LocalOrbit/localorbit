class Discount < ActiveRecord::Base
  include SoftDelete
  include Sortable

  self.inheritance_column = nil

  belongs_to :market
  belongs_to :buyer_organization, class_name: "Organization"
  belongs_to :seller_organization, class_name: "Organization"

  enum type: {percentage: 0, fixed: 1}

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :type, presence: true
  validates :discount, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647}
  validates :minimum_order_total, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647}
  validates :maximum_order_total, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647}
  validates :maximum_uses, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647}
  validates :maximum_organization_uses, numericality: {greater_than_or_equal_to: 0, less_than: 2_147_483_647}
  validate :starts_before_it_ends
  validate :future_end_date

  def value_for(subtotal)
    if percentage?
      (subtotal * (discount / 100)).round(2)
    elsif fixed?
      [subtotal, discount].min
    else
      Honeybadger.notify(
        error_class:   "Invalid Discount Code",
        error_message: "Discount code has an unknown type",
        parameters:    {discount_id: id}
      )
      0
    end
  end

  def active?
    (start_date.nil? || start_date < Time.current) && (end_date.nil? || end_date > Time.current)
  end

  def total_uses
    Order.where(discount_id: id).count
  end

  def uses_by_organization(organization)
    Order.where(organization_id: organization.id, discount_id: id).count
  end

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
