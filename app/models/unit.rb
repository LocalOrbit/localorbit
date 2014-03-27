class Unit < ActiveRecord::Base
  scope :for_display, lambda { order(:plural) }
end
