module Sortable
  extend ActiveSupport::Concern

  def column_and_direction(string)
    column, direction = string.split(":").map(&:to_sym)
    direction = :asc unless direction.include?(:asc, :desc)
    [column, direction]
  end
end
