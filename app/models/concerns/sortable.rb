module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def column_and_direction(string)
      column, direction = string.split("-")
      direction = "asc" unless ["asc", "desc"].include?(direction)
      [column, direction]
    end
  end
end
