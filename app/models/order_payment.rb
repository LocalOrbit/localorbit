class OrderPayment < ActiveRecord::Base
  belongs_to :order
  belongs_to :payment
end
