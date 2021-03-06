class Cart < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :market
  belongs_to :organization
  belongs_to :user
  belongs_to :delivery
  belongs_to :location, -> { visible }
  belongs_to :discount

  validates :organization, presence: true
  validates :market, presence: true
  validates :user, presence: true
  validates :delivery, presence: true

  has_many :items, -> { includes(product: [:prices, :organization]) }, class_name: :CartItem, inverse_of: :cart do
    def for_checkout
      eager_load(product: [:organization, :prices]).order("organizations.name, products.name").group_by do |item|
        item.product.organization.name
      end
    end
  end

  def delivery_location
    if delivery.delivery_schedule.buyer_pickup?
      delivery.delivery_schedule.buyer_pickup_location
    elsif organization.locations.visible.length > 1
      location
    elsif !organization.shipping_location.nil?
      organization.shipping_location
    end
  end

  def subtotal
    (@subtotal ||= items.each.sum(&:total_price)).round(2)
  end

  def has_valid_discount?
    discount.try(:valid_for_cart?, self) || false
  end

  def discount_amount
    order_total = if discount.try(:seller_organization_id).present?
      delivery_fees + items.joins(:product).where(products: {organization_id: discount.seller_organization_id}).each.sum(&:total_price)
    else
      delivery_fees + subtotal
    end

    (@discount_amount ||= discount.try(:valid_for_cart?, self) ? discount.value_for(order_total) : 0).round(2)
  end

  def discount_code
    discount.try(:code)
  end

  def delivery_fees
    delivery.delivery_schedule.fees_for_amount(subtotal).round(2)
  end

  def total
    (subtotal + delivery_fees - discount_amount).round(2)
  end
end
