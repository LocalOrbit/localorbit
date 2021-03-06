module FinancialOverview
  class MarketManager < FinancialOverview::Base
    def initialize(opts={})
      super
      @calculation_method = :gross_total
      @partial = "market_manager"

      #base_order_scope = Order.orders_for_seller(@user).where(market: @market)
      base_order_scope = @orders
      @cc_ach_orders = base_order_scope.paid_with(["credit card", "ach"])
      @po_orders = base_order_scope.paid_with("purchase order")
    end

    def overdue
      orders = @po_orders.delivered.payment_overdue
      sum_order_total(orders)
    end

    def money_out_next_seven
      orders = @po_orders.delivered.paid_between(next_seven_days(offset: -7))
      sum_money_to_sellers(orders)
    end

    def money_in_today
      orders = @po_orders.invoiced.unpaid.due_between(today)
      sum_order_total(orders)
    end

    def money_in_next_seven
      orders = @po_orders.invoiced.unpaid.due_between(next_seven_days)
      sum_order_total(orders)
    end

    def money_in_next_thirty
      orders = @po_orders.invoiced.unpaid.due_between(next_thirty_days)
      sum_order_total(orders)
    end

    def money_in_purchase_orders
      orders = @po_orders.uninvoiced
      sum_order_total(orders)
    end

    def lo_fees_next_seven_days
      orders = @po_orders.paid_between(next_seven_days(offset: -7))
      sum_local_orbit_fees(orders)
    end

    private

    def sum_order_total(orders)
      orders.map(&:total_cost).compact.reduce(:+) || 0
    end

    def sum_money_to_sellers(orders)
      orders.inject(0) do |total, order|
        snt = order.items.map(&:seller_net_total).reduce(:+)
        if !snt.nil?
          total + snt
        else
          total + 0
        end
      end
    end

    def sum_local_orbit_fees(orders)
      orders.inject(0) do |total, order|
        lomf = order.items.sum(:local_orbit_market_fee)
        if !lomf.nil?
          total + lomf
        else
          total + 0
        end
      end
    end
  end
end
