class Unit < ActiveRecord::Base
  scope :for_display, -> { order(:plural) }
end
