class OrderPolicy < ApplicationPolicy

  class Scope < Struct.new(:order, :scope)
    def resolve
      scope
    end
  end
end