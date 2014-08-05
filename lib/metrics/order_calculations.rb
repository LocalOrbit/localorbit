module Metrics
  class OrderCalculations < Base
    BASE_SCOPE = Order.joins(<<-SQL
        INNER JOIN (
          SELECT DISTINCT orders_alias2.id
          FROM orders orders_alias2
          INNER JOIN order_items order_items_alias
            ON order_items_alias.order_id = orders_alias2.id
            AND order_items_alias.delivery_status != 'canceled'
        ) orders_alias ON orders_alias.id = orders.id
      SQL
    ).joins(:market).where.not(market_id: TEST_MARKET_IDS)

    MODEL_NAME = BASE_SCOPE.name

    METRICS = {
      total_orders: {
        title: "Total Orders",
        scope: BASE_SCOPE,
        attribute: :placed_at,
        calculation: :count
      },
      total_orders_percent_growth: {
        title: "Total Orders % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_orders,
        format: :percent
      },
      average_order: {
        title: "Average Order",
        scope: BASE_SCOPE.joins(:items),
        attribute: :placed_at,
        calculation: :custom,
        calculation_arg: "(SUM(order_items.unit_price * COALESCE(order_items.quantity_delivered, order_items.quantity))::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)",
        format: :currency
      },
      average_order_size: {
        title: "Average Items Per Order",
        scope: BASE_SCOPE.joins(:items),
        attribute: :placed_at,
        calculation: :custom,
        calculation_arg: "(COUNT(DISTINCT order_items.id)::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)",
        format: :decimal
      },
      # Total Delivery Fees
      # Total of order delivery fees excluding orders without a delivery fee
      #
      # Order#delivery_fees when Order#delivery_fees is present
      total_delivery_fees: {
        title: "Total Delivery Fees",
        scope: BASE_SCOPE.where.not(delivery_fees: [nil, 0]),
        attribute: :placed_at,
        calculation: :sum,
        calculation_arg: :delivery_fees,
        format: :currency
      },
      total_delivery_fees_percent_growth: {
        title: "Total Delivery Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_delivery_fees,
        format: :percent
      },
      # Average Delivery Fees
      # Average of order delivery fees excluding orders without a delivery fee
      #
      # Order#delivery_fees when Order#delivery_fees is present
      average_delivery_fees: {
        title: "Average Delivery Fees",
        scope: BASE_SCOPE.where.not(delivery_fees: [nil, 0]),
        attribute: :placed_at,
        calculation: :average,
        calculation_arg: :delivery_fees,
        format: :currency
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::OrderCalculations::METRICS)
