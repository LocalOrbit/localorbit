class OrderItem < ActiveRecord::Base
  belongs_to :order, inverse_of: :items

  validates :name, presence: true
  validates :order_id, presence: true
  validates :seller_name, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :unit_price, presence: true
end
