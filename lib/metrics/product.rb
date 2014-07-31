module Metrics
  class Product < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Product"
    @@base_scope = ::Product
    @@metrics = {
      total_products_simple:   self.base_scope.where(use_simple_inventory: true),
      total_products_advanced: self.base_scope.where(use_simple_inventory: false)
    }
  end
end
