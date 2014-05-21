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
    end

    def purchase_orders
    end
  end
end
