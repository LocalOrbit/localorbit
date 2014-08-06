module Metrics
  class OrderItemCalculations < Base
    BASE_SCOPE = OrderItem.joins(order: :market).where.not(orders: {market_id: TEST_MARKET_IDS}, delivery_status: "canceled")
    METRICS = {
      number_of_items: {
        title: "Number of Items",
        scope: BASE_SCOPE,
        attribute: "orders.placed_at",
        calculation: :count,
      },
      total_sales: {
        title: "Total Sales",
        scope: BASE_SCOPE,
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "unit_price * COALESCE(quantity_delivered, quantity)",
        format: :currency
      },
      total_sales_percent_growth: {
        title: "Total Sales % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_sales,
        format: :percent
      },
      total_transaction_fees: {
        title: "Total Transaction Fees",
        scope: BASE_SCOPE,
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "order_items.local_orbit_seller_fee + order_items.local_orbit_market_fee",
        format: :currency
      },
      total_transaction_fees_percent_growth: {
        title: "Total Transaction Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_transaction_fees,
        format: :percent
      },
      # Credit Card Processing Fees
      # What LO charges customers for credit card processing payments
      #
      # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
      # when Order#payment_method is "credit_card"
      credit_card_processing_fees: {
        title: "Credit Card Processing Fees",
        scope: BASE_SCOPE.where(orders: {payment_method: "credit card"}),
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "order_items.payment_seller_fee + order_items.payment_market_fee",
        format: :currency
      },
      credit_card_processing_fees_percent_growth: {
        title: "Credit Card Processing Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :credit_card_processing_fees,
        format: :percent
      },
      # ACH Processing Fees
      # What LO charges customers for credit card processing payments
      #
      # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
      # when Order#payment_method is "ach"
      ach_processing_fees: {
        title: "ACH Processing Fees",
        scope: BASE_SCOPE.where(orders: {payment_method: "ach"}),
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "order_items.payment_seller_fee + order_items.payment_market_fee",
        format: :currency
      },
      ach_processing_fees_percent_growth: {
        title: "ACH Processing Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :ach_processing_fees,
        format: :percent
      },
      # Total Payment Processing Fees:
      # What LO charges customers for credit card + ACH processing payments
      #
      # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
      # when Order#payment_method is "credit_card" or "ach"
      total_processing_fees: {
        title: "Total Processing Fees",
        scope: BASE_SCOPE.where(orders: {payment_method: ["credit card", "ach"]}),
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "order_items.payment_seller_fee + order_items.payment_market_fee",
        format: :currency
      },
      total_processing_fees_percent_growth: {
        title: "Total Processing Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_processing_fees,
        format: :percent
      },
      # Total Market Fees
      # Fees charged to a Market for payments and LO fees
      #
      # OrderItem#payment_market_fee + OrderItem#local_orbit_market_fee
      total_market_fees: {
        title: "Total Market Fees",
        scope: BASE_SCOPE,
        attribute: "orders.placed_at",
        calculation: :sum,
        calculation_arg: "market_seller_fee",
        format: :currency
      },
      total_market_fees_percent_growth: {
        title: "Total Market Fees % Growth",
        calculation: :percent_growth,
        calculation_arg: :total_market_fees,
        format: :percent
      }
    }
  end
end

Metrics::Base.register_metrics(Metrics::OrderItemCalculations::METRICS)
