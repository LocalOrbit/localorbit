module FinancialOverview
  class MarketManager < FinancialOverview::Base
    def initialize(opts={})
      super
      @calculation_method = :gross_total
    end

    def overdue
      sum_order_total(@po_orders.delivered.where("invoice_due_date < ?", @time.beginning_of_day))
    end

    def money_out_next_seven
      orders = @po_orders.delivered.paid_between(
        next_seven_days(offset: -7)
      )

      sum_money_to_sellers(orders)
    end

    def money_in_today
      orders = @po_orders.due_between(today)
      sum_order_total(orders)
    end

    def money_in_next_seven
      orders = @po_orders.invoiced.unpaid.due_between(next_seven_days)
      sum_order_total(orders)
    end

    def money_in_next_thirty
      # Don't include the "next 7 days" total
      start = (next_seven_days.end + 1.day).beginning_of_day
      orders = @po_orders.invoiced.unpaid.due_between(start..next_thirty_days.end)
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
      orders.map(&:total_cost).reduce(:+) || 0
    end

    def sum_money_to_sellers(orders)
      orders.inject(0) do |total, order|
        total + order.items.map(&:seller_net_total).reduce(:+)
      end
    end

    def sum_local_orbit_fees(orders)
      orders.inject(0) do |total, order|
        total + order.items.sum(:local_orbit_market_fee)
      end
    end
  end
end
