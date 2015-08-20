# This allows you to use SELECT DISTINCT in conjunction with a Ransack sort.
# See https://github.com/activerecord-hackery/ransack/issues/429

module Ransack
  module Adapters
    module ActiveRecord
      class Context < ::Ransack::Context
        def evaluate(search, opts = {})
          viz = Visitor.new
          relation = @object.where(viz.accept(search.base))
          if search.sorts.any?
            _vaccept = viz.accept(search.sorts)
            table  = _vaccept.first.expr.relation.name
            column = _vaccept.first.expr.name
            relation = relation.except(:order).reorder(_vaccept).select("#{@default_table.name}.*, #{table}.#{column}")
          end
          opts[:distinct] ? relation.uniq : relation
        end
      end
    end
  end
end