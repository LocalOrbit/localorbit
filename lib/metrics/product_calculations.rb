module Metrics
  class ProductCalculations < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Product"
    @@base_scope = Product.joins(organization: :markets).where.not(organization_id: MetricsPresenter::TEST_ORG_IDS).uniq
    @@metrics = {
      total_products: {
        title: "Total Products",
        scope: @@base_scope,
        attribute: "products.created_at",
        calculation: :window,
        calculation_arg: "products.id",
        format: :integer
      },
      total_products_simple: {
        title: "Total Products Using Simple Inventory",
        scope: @@base_scope,
        calculation: :metric,
        format: :integer
      },
      total_products_advanced: {
        title: "Total Products Using Advanced Inventory",
        scope: @@base_scope,
        calculation: :metric,
        format: :integer
      },
      total_products_ordered: {
        title: "Total Products Ordered",
        scope: @@base_scope.joins(:orders),
        attribute: "orders.placed_at",
        calculation: :count,
        calculation_arg: "products.id",
        format: :integer
      },
      average_product_price: {
        title: "Average Product Price",
        scope: @@base_scope.joins(:prices),
        attribute: :placed_at,
        calculation: :custom,
        calculation_arg: "(COUNT(DISTINCT products.id)::NUMERIC / AVERAGE(price.sale_price)::NUMERIC)",
        format: :decimal
      }
    }
  end
end
