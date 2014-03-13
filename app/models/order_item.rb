class OrderItem < ActiveRecord::Base
  belongs_to :order, inverse_of: :items
  belongs_to :product

  validates :name, presence: true
  validates :order, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true

  def seller_net_total
    unit_price * quantity - market_fees - localorbit_seller_fees - payment_seller_fees
  end

  def gross_total
    unit_price * quantity
  end
end
