# To use, implement an arel_column_for_sort class method
# on the model and include this module.
module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def arel_column_for_sort(_column_name)
      raise "method not implemented"
    end

    def for_sort(order)
      column_name, direction = column_and_direction(order)
      arel_column = arel_column_for_sort(column_name)
      direction == "asc" ? order(arel_column.asc) : order(arel_column.desc)
    end

    def column_and_direction(string)
      column, direction = string.split("-")
      direction = "asc" unless direction == "desc"
      [column, direction]
    end
  end
end
