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
    return 0 unless discount
    @discount_amount ||= discount.value_for(subtotal)
  end

  def delivery_fees
    delivery.delivery_schedule.fees_for_amount(subtotal)
  end

  def total
    subtotal + delivery_fees - discount_amount
  end
end
