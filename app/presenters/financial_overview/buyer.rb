module FinancialOverview
  class Buyer < FinancialOverview::Base
    def initialize(opts={})
      super
      @partial = "buyer"

      @po_orders = Order.orders_for_buyer(@user)
    end

    def overdue
      @po_orders.payment_overdue.sum(:total_cost)
    end

    def due
      @po_orders.invoiced.unpaid.sum(:total_cost) - overdue
    end

    def purchase_orders
      @po_orders.uninvoiced.sum(:total_cost)
    end
  end
end
