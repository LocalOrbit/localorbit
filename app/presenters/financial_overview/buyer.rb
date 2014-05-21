module FinancialOverview
  class Buyer < FinancialOverview::Base
    def initialize(opts={})
      super
      @partial = "buyer"
    end

    def due
    end

    def purchase_orders
    end
  end
end
