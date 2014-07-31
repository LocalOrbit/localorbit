module Metrics
  class ProductHistory < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Product"
    @@base_scope = ::Product.where.not(organization_id: MetricsPresenter::TEST_ORG_IDS).uniq
    @@metrics = {
      total_products_simple:   self.base_scope.where(use_simple_inventory: true),
      total_products_advanced: self.base_scope.where(use_simple_inventory: false)
    }
  end
end
