class ConsignmentTransaction < ActiveRecord::Base
  belongs_to :product
  belongs_to :lot
  belongs_to :order
end