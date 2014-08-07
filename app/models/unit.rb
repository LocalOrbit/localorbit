class Unit < ActiveRecord::Base
  audited allow_mass_assignment: true
  scope :for_display, -> { order(:plural) }
end
