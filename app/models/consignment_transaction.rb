class ConsignmentTransaction < ActiveRecord::Base

  include SoftDelete

  belongs_to :product
  belongs_to :lot
  belongs_to :order
end