class MetricsPresenter
  attr_reader :metrics, :q

  METRICS = {
    number_of_orders: {
      title: "# of Orders",
      scope: Order.joins(:items).where.not(order_items: { delivery_status: "canceled" }),
      attribute: :placed_at,
      calculation: :count
    },
    number_of_items: {
      title: "# of Items",
      scope: OrderItem.joins(:order).where.not(delivery_status: "canceled"),
      attribute: "orders.placed_at",
      calculation: :count,
    },
    total_sales: {
      title: "Total Sales",
      scope: OrderItem.joins(:order).where.not(delivery_status: "canceled"),
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "unit_price * quantity"
    },
    average_order: {
      title: "Average Order",
      scope: OrderItem.joins(:order).where.not(delivery_status: "canceled"),
      attribute: "orders.placed_at",
      calculation: :average,
      calculation_arg: "unit_price * quantity"
    },
    average_number_items: {
      title: "Average # Items",
      scope: Order.joins(:items).where.not(order_items: { delivery_status: "canceled" }),
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(COUNT(DISTINCT order_items.id)::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)"
    }
  }

  GROUPS = {
    financials: {
      title: "Financials",
      metrics: [
        :number_of_orders, :total_sales, :average_order, :average_number_items
      ]
    }
    # :avg_lo_fees, :avg_lo_fee_pct, :sales_pct_growth, :lo_fees, :fee_pct_growth, :service_fees
  }

  def initialize(groups: [], search: {})
    # {
    #   "Group Title" => {
    #     "Metric Title" => {
    #       "Jan 2013" => 123,
    #       "Feb 2013" => 321,
    #       "Mar 2013" => 123,
    #       "Apr 2013" => 321,
    #       "May 2013" => 123,
    #       "Jun 2013" => 321,
    #     }
    #   }
    # }
    @metrics = Hash[
      groups.map do |group|
        [GROUPS[group][:title], metrics_for_group(group)]
      end
    ]
  end

  def self.metrics_for(groups: [], search: {})
    search ||= {}
    groups = [groups].flatten

    new(groups: groups, search: search)
  end

  private

  def metrics_for_group(group)
    Hash[
      GROUPS[group][:metrics].map do |metric|
        [METRICS[metric][:title], calculate_metric(metric, :month)]
      end
    ]
  end

  def scope_for(scope:, attribute:, interval:)
    case interval
    when :week
      scope.group_by_week(attribute,
                          range: 4.weeks.ago.beginning_of_week..Time.now,
                          format: "%-m/%-d/%Y")
    when :month
      scope.group_by_month(attribute,
                           range: 5.months.ago.beginning_of_month..Time.now,
                           format: "%b %Y")
    end
  end

  def calculate_metric(metric, interval)
    m = METRICS[metric]

    scope = m[:scope].uniq
    scope = scope_for(scope: scope, attribute: m[:attribute], interval: interval)

    if m[:calculation] == :custom
      scope.group_calc(m[:calculation_arg])
    else
      scope.send(m[:calculation], m[:calculation_arg])
    end
  end
end
