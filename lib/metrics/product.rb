module Metrics
  class Product < Base
    BASE_SCOPE = ::Product
    METRICS = {
      total_products_simple:   BASE_SCOPE.where(use_simple_inventory: true),
      total_products_advanced: BASE_SCOPE.where(use_simple_inventory: false)
    }
  end

  def initialize
    super(
      base_scope: BASE_SCOPE,
      metrics: METRICS,
      model_name: "Organization"
    )
  end
end
