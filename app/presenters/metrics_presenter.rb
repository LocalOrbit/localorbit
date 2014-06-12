class MetricsPresenter
  attr_reader :metrics, :q

  METRIC_MAP = {
    num_orders: {
      title: "# of Order",
      scope: Order,
      attribute: :placed_at,
      calculation: :count
    },
    total_sales: {
      title: "Total Sales",
      scope: Order,
      attribute: :placed_at,
      calculation: :count
    }
  }

  CONTEXT_MAP = {
    financials: [
      :num_orders, :total_sales, :avg_order, :avg_num_items, :avg_lo_fees,
      :avg_lo_fee_pct, :sales_pct_growth, :lo_fees, :fee_pct_growth, :service_fees
    ]
  }.with_indifferent_access

  def calculate_metric(metric, interval)
    metric_def = METRIC_MAP[metric]

    scope = metric_def[:scope].uniq

    scope = case interval
            when :week
              scope.group_by_week(metric_def[:attribute],
                                  range: 4.weeks.ago.beginning_of_week..Time.now,
                                  format: "%-m/%-d/%Y")
            else # when :month
              scope.group_by_month(metric_def[:attribute],
                                   range: 5.months.ago.beginning_of_month..Time.now,
                                   format: "%b %Y")
            end

    scope.send(metric_def[:calculation])
  end

  def calculate_metrics_for(context)
    Hash[
      CONTEXT_MAP[context].each do |metric|
        [METRIC_MAP[metric][:title], calculate_metric(metric, :week)]
      end
    ]
  end
end
