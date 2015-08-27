class Discount < ActiveRecord::Base
  audited allow_mass_assignment: true
  include SoftDelete
  include Sortable

  self.inheritance_column = nil

  belongs_to :market
  belongs_to :buyer_organization, class_name: "Organization"
  belongs_to :seller_organization, class_name: "Organization"

  enum payer: {market: 0, seller: 1}
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
    time_now = Time.current.end_of_minute
    (start_date.nil? || start_date < time_now) && (end_date.nil? || end_date > time_now)
  end

  def valid_for_cart?(cart)
    can_use_in_market?(cart) &&
    can_use_for_buyer?(cart) &&
    !less_than_minimum?(cart) &&
    !more_than_maximum?(cart) &&
    !maximum_uses_hit? &&
    !maximum_organization_uses_hit?(cart)
  end

  def can_use_in_market?(cart)
    market_id.nil? || market_id == cart.market_id
  end

  def can_use_for_buyer?(cart)
    buyer_organization_id.nil? || buyer_organization_id == cart.organization.id
  end

  def less_than_minimum?(cart)
    minimum_order_total > 0 && minimum_order_total > cart.subtotal
  end

  def more_than_maximum?(cart)
    maximum_order_total > 0 && maximum_order_total < cart.subtotal
  end

  def maximum_uses_hit?
    maximum_uses > 0 && maximum_uses <= total_uses
  end

  def maximum_organization_uses_hit?(cart)
    maximum_organization_uses > 0 && maximum_organization_uses <= uses_by_organization(cart.organization)
  end

  def requires_seller_items?(cart)
    seller_organization_id.present? && cart.items.joins(:product).where(products: {organization_id: seller_organization.id}).none?
  end

  def total_uses
    Order.where(discount_id: id).count
  end

  def uses_by_organization(organization)
    Order.where(organization_id: organization.id, discount_id: id).count
  end

  private

  def future_end_date
    errors.add(:end_date, "must be in the future") if end_date && (!persisted? || end_date_changed?) && end_date < Time.current.end_of_minute
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
