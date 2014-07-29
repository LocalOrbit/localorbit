module Metrics
  class Product < Base
    BASE_SCOPE = ::Product
    METRICS = {
      total_products_simple:   BASE_SCOPE.where(use_simple_inventory: true),
      total_products_advanced: BASE_SCOPE.where(use_simple_inventory: false)
    }.with_indifferent_access
  end
end
