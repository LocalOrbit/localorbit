class MetricsPresenter
  attr_reader :metrics, :headers

  TEST_MARKET_IDS = [10]
  TEST_ORG_IDS    = Market.where(id: TEST_MARKET_IDS).joins(:organizations).uniq.pluck("organizations.id")

  GROUPDATE_OPTIONS = {
    week: {
      groupdate: :group_by_week,
      last: 5,
      format: "%-m/%-d/%Y"
    },
    month: {
      groupdate: :group_by_month,
      last: 6,
      format: "%b %Y"
    }
  }.freeze

  BASE_SCOPES = {
    order: Order.joins(:items).where.not(market_id: TEST_MARKET_IDS, order_items: { delivery_status: "canceled" }),
    order_item: OrderItem.joins(:order).where.not(orders: { market_id: TEST_MARKET_IDS }, delivery_status: "canceled"),
    payment: Payment.where.not(market_id: TEST_MARKET_IDS),
    market: Market.where.not(id: TEST_MARKET_IDS),
    organization: Organization.where.not(id: TEST_ORG_IDS)
  }

  METRICS = {
    total_orders: {
      title: "Total Orders",
      scope: BASE_SCOPES[:order],
      attribute: :placed_at,
      calculation: :count
    },
    number_of_items: {
      title: "Number of Items",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :count,
    },
    total_sales: {
      title: "Total Sales",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "unit_price * quantity"
    },
    average_order: {
      title: "Average Order",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :average,
      calculation_arg: "unit_price * quantity"
    },
    average_order_size: {
      title: "Average Order Size",
      scope: BASE_SCOPES[:order],
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(COUNT(DISTINCT order_items.id)::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)"
    },
    total_service_fees: {
      title: "Total Service Fees",
      scope: BASE_SCOPES[:payment].where(payment_type: 'service'),
      attribute: "created_at",
      calculation: :sum,
      calculation_arg: :amount
    },
    total_transaction_fees: {
      title: "Total Transaction Fees",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "local_orbit_seller_fee + local_orbit_market_fee"
    },
    total_markets: {
      title: "Total Markets",
      scope: BASE_SCOPES[:market],
      attribute: :created_at,
      calculation: :window
    },
    active_markets: {
      title: "Active Markets",
      scope: BASE_SCOPES[:order].joins(:market),
      attribute: :placed_at,
      calculation: :count,
      calculation_arg: "DISTINCT(markets.id)"
    },
    total_organizations: {
      title: "Total Organizations",
      scope: BASE_SCOPES[:organization],
      attribute: :created_at,
      calculation: :window
    },
    total_buyer_only: {
      title: "Total Buyers Only",
      scope: BASE_SCOPES[:organization].where(can_sell: false),
      attribute: :created_at,
      calculation: :window
    },
    # Formula: all buyers + any seller that has bought
    total_buyers: {
      title: "Total Buyers",
      scope: BASE_SCOPES[:organization].where(can_sell: false),
      attribute: :created_at,
      calculation: :window
    },
    total_sellers: {
      title: "Total Sellers",
      scope: BASE_SCOPES[:organization].where(can_sell: true),
      attribute: :created_at,
      calculation: :window
    },
  }

  GROUPS = {
    financials: {
      title: "Financials",
      metrics: [
        :total_orders, :number_of_items, :total_sales, :average_order, :average_order_size,
        :total_service_fees, :total_transaction_fees
      ]
    },
    markets: {
      title: "Markets",
      metrics: [
        :total_markets, :active_markets, :total_organizations, :total_buyer_only,
        :total_buyers, :total_sellers
      ]
    },
    users: {
      title: "Users",
      metrics: [
      ]
    },
    products: {
      title: "Products",
      metrics: [
      ]
    }
    # :avg_lo_fees, :avg_lo_fee_pct, :sales_pct_growth, :lo_fees, :fee_pct_growth, :service_fees
  }.with_indifferent_access

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

    @headers ||= []
  end

  def self.metrics_for(groups: [], search: {})
    search ||= {}
    groups = [groups].flatten

    new(groups: groups, search: search)
  end

  # private

  def metrics_for_group(group)
    Hash[
      GROUPS[group][:metrics].map do |metric|
        [METRICS[metric][:title], calculate_metric(metric, :month)]
      end
    ]
  end

  def scope_for(scope:, attribute:, interval:, window: false)
    options = GROUPDATE_OPTIONS[interval].dup
    groupdate = options.delete(:groupdate)

    if window
      options[:carry_forward] = true
      options.delete(:last)
    end

    scope.send(groupdate, attribute, options)
  end

  def calculate_metric(metric, interval)
    m = METRICS[metric]
    scope = m[:scope].uniq

    values = if m[:calculation] == :custom
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval)
      series.group_calc(m[:calculation_arg])

    elsif m[:calculation] == :window
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval, window: true)
      values = series.group_calc("SUM(COUNT(DISTINCT(id))) OVER (ORDER BY #{series.relation.group_values[0]})")

      # we have to calculate all history when using windows so we need to only
      # return the last X values from the result set
      values.to_a.last(GROUPDATE_OPTIONS[interval][:last]).to_h

    else
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval)
      series.send(m[:calculation], m[:calculation_arg])
    end

    # set our headers for this result set
    @headers ||= values.keys

    values
  end
end
