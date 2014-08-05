module Metrics
  class ProductHistory < ProductCalculations
    cattr_accessor :history_metrics, :model_name

    @@model_name = BASE_SCOPE.name
    @@history_metrics = {
      total_products_simple:   { scope: BASE_SCOPE.where(use_simple_inventory: true) },
      total_products_advanced: { scope: BASE_SCOPE.where(use_simple_inventory: false) }
    }
  end
end
