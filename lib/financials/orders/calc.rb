module Financials
  module Orders
    class Calc
      class << self
        def gross_item_total(items:)
          DataCalc.sum_of_field(items, :gross_total, default: 0.to_d)
        end
      end
    end
  end
end
