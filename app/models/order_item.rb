class OrderItem < ActiveRecord::Base
  belongs_to :order, inverse_of: :items, autosave: true
  belongs_to :product
  has_many :lots, inverse_of: :order_item

  validates :name, presence: true
  validates :order, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true

  def self.build_from_cart_item(item)
    OrderItem.new(
      product: item.product,
      name: item.product.name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price.sale_price,
      seller_name: item.product.organization.name
    )
  end

  def seller_net_total
    unit_price * quantity - market_fees - localorbit_seller_fees - payment_seller_fees
  end

  def gross_total
    unit_price * quantity
  end
end
