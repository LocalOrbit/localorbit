class Payment < ActiveRecord::Base
  has_many :order_payments, inverse_of: :payment
  has_many :orders, through: :order_payments, inverse_of: :payments
end
