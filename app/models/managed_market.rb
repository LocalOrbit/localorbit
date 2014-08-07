class ManagedMarket < ActiveRecord::Base
  audited allow_mass_assignment: true
  belongs_to :market
  belongs_to :user
end
