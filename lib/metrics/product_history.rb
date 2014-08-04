module Metrics
  class ProductHistory < ProductCalculations
    cattr_accessor :history_metrics

    @@history_metrics = {
      total_products_simple:   { scope: self.base_scope.where(use_simple_inventory: true) },
      total_products_advanced: { scope: self.base_scope.where(use_simple_inventory: false) }
    }
  end
end
