class ProductDelivery < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :product
  belongs_to :delivery_schedule
end
