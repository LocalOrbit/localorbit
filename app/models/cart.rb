class Cart < ActiveRecord::Base
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

  has_many :items, -> { includes(product: :organization) }, class_name: :CartItem, inverse_of: :cart do
    def for_checkout
      joins(product: :organization).order("organizations.name, products.name").group_by do |item|
        item.product.organization.name
      end
    end
  end

  def delivery_location
    if delivery.delivery_schedule.buyer_pickup?
      delivery.delivery_schedule.buyer_pickup_location
    else
      location || organization.shipping_location
    end
  end

  def subtotal
    @subtotal ||= items.each.sum(&:total_price)
  end

  def discount_amount
    item_total = if discount.try(:seller_organization_id).present?
      items.joins(:product).where(products: {organization_id: discount.seller_organization_id}).each.sum(&:total_price)
    else
      subtotal
    end

    @discount_amount ||= discount.try(:value_for, item_total) || 0
  end

  def discount_code
    discount.try(:code)
  end

  def delivery_fees
    delivery.delivery_schedule.fees_for_amount(subtotal)
  end

  def total
    subtotal + delivery_fees - discount_amount
  end
end
