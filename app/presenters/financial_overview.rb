module FinancialOverview
  def self.build(user, market)
    klass = if user.can_manage_market?(market)
      MarketManager
    elsif user.buyer_only?(market)
      Buyer
    else
      Seller
    end

    klass.new(user: user, market: market)
  end

  class Base
    attr_reader :partial

    def initialize(opts={})
      @user = opts[:user]
      @market = opts[:market]
      @time = Time.current
    end

    def next_seven_days(offset: 0)
      range_start = (@time + 1.day).beginning_of_day + offset.days
      range_end = (range_start + 6.days).end_of_day

      range_start..range_end
    end

    def next_thirty_days(offset: 0)
      range_start = (@time + 1.day).beginning_of_day + offset.days
      range_end = (range_start + 29.days).end_of_day

      range_start..range_end
    end

    def today(offset: 0)
      start_of_day = (@time).beginning_of_day + offset.days
      end_of_day = start_of_day.end_of_day

      start_of_day..end_of_day
    end

    def overdue
      sum_seller_items(@po_orders.delivered.where("invoice_due_date < ?", @time.beginning_of_day))
    end

    private

    def sum_seller_items(orders)
      orders.inject(0) do |total, order|
        total + order.items.for_user(@user, @market).map(&@calculation_method).reduce(:+)
      end
    end
  end
end
