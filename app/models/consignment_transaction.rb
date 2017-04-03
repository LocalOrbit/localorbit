class ConsignmentTransaction < ActiveRecord::Base
  audited allow_mass_assignment: true

  include SoftDelete

  belongs_to :product
  belongs_to :lot
  belongs_to :order
end