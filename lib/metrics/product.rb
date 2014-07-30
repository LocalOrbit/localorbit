module Metrics
  class Product < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Product"
    @@base_scope = ::Product
    @@metrics = {
      total_products_simple:   BASE_SCOPE.where(use_simple_inventory: true),
      total_products_advanced: BASE_SCOPE.where(use_simple_inventory: false)
    }
  end
end
