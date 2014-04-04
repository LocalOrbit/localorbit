class ProductDelivery < ActiveRecord::Base
  belongs_to :product
  belongs_to :delivery_schedule
end
