class MetricsPresenter
  include ActiveSupport::NumberHelper

  attr_reader :metrics, :headers

  START_OF_WEEK = :sun

  TEST_MARKET_IDS = Market.where(demo: true).pluck(:id)
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
      calculation_arg: "unit_price * COALESCE(quantity_delivered, quantity)",
      format: :currency
    },
    average_order: {
      title: "Average Order",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :average,
      calculation_arg: "unit_price * COALESCE(quantity_delivered, quantity)",
      format: :currency
    },
    average_order_size: {
      title: "Average Order Size",
      scope: BASE_SCOPES[:order],
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(COUNT(DISTINCT order_items.id)::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)",
      format: :decimal
    },
    total_service_fees: {
      title: "Total Service Fees",
      scope: BASE_SCOPES[:payment].where(payment_type: 'service'),
      attribute: "created_at",
      calculation: :sum,
      calculation_arg: :amount,
      format: :currency
    },
    total_transaction_fees: {
      title: "Total Transaction Fees",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "local_orbit_seller_fee + local_orbit_market_fee",
      format: :currency
    },
    total_markets: {
      title: "Total Markets",
      scope: BASE_SCOPES[:market],
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    live_markets: {
      title: "Live Markets",
      scope: BASE_SCOPES[:market].where(active: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    active_markets: {
      title: "Active Markets",
      scope: BASE_SCOPES[:order].joins(:market),
      attribute: :placed_at,
      calculation: :count,
      calculation_arg: "DISTINCT(markets.id)",
      format: :integer
    },
    total_organizations: {
      title: "Total Organizations",
      scope: BASE_SCOPES[:organization],
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_buyer_only: {
      title: "Total Buyers Only",
      scope: BASE_SCOPES[:organization].where(can_sell: false),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    # union of all buyers + any seller that has bought
    total_buyers: {
      title: "Total Buyers",
      scope: Organization.where(Organization.arel_table[:id].in(BASE_SCOPES[:organization].select(:id).where(can_sell: false).union(BASE_SCOPES[:organization].select(:id).joins(:orders)))),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_sellers: {
      title: "Total Sellers",
      scope: BASE_SCOPES[:organization].where(can_sell: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_buyer_orders: {
      title: "Buyers Placing Orders",
      scope: BASE_SCOPES[:organization].joins(:orders),
      attribute: "orders.placed_at",
      calculation: :count,
      format: :integer
    },
  }

  GROUPS = {
    financials: {
      title: "Financials",
      metrics: [
        :total_orders, :total_sales, :average_order, :average_order_size,
        :total_service_fees, :total_transaction_fees
      ]
    },
    markets: {
      title: "Markets",
      metrics: [
        :total_markets, :live_markets, :active_markets
      ]
    },
    users: {
      title: "Users",
      metrics: [
        :total_organizations, :total_buyer_only, :total_sellers, :total_buyers, :total_buyer_orders,
      ]
    },
    products: {
      title: "Products",
      metrics: [
        :number_of_items
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

    interval = :month
    @headers = headers_for_interval(interval)

    @metrics = Hash[
      groups.map do |group|
        [GROUPS[group][:title], metrics_for_group(group, interval)]
      end
    ]
  end

  def self.metrics_for(groups: [], search: {})
    search ||= {}
    groups = [groups].flatten

    return nil unless groups.all? { |group| GROUPS.keys.include?(group) }

    new(groups: groups, search: search)
  end

  private

  def metrics_for_group(group, interval)
    Hash[
      GROUPS[group][:metrics].map do |metric|
        [METRICS[metric][:title], calculate_metric(metric, interval)]
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
      values = series.group_calc("SUM(COUNT(DISTINCT(#{m[:calculation_arg] || "id"}))) OVER (ORDER BY #{series.relation.group_values[0]})")

      # we have to calculate all history when using windows so we need to only
      # return the last X values from the result set
      format_values(values, interval)
    else
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval)
      series.send(m[:calculation], m[:calculation_arg])
    end

    Hash[values.map { |key, value| [key, format_value(value, m[:format])] }]
  end

  def format_value(value, format)
    value ||= 0

    case format
    when :integer  then value.to_i
    when :decimal  then value.try(:round, 2)
    when :currency then number_to_currency(value)
    else value
    end
  end

  def format_values(values, interval)
    count = GROUPDATE_OPTIONS[interval][:last]

    Hash[@headers.map { |header| [header, (values[header] || values.values.last || 0)] }.last(count)]
  end

  def headers_for_interval(interval)
    if interval == :month
      end_date = Date.current.beginning_of_month
      (0..5).map { |x| (end_date - x.months).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    elsif interval == :week
      end_date = Date.current.beginning_of_week - (START_OF_WEEK == :sun ? 1 : 0).days
      (0..4).map { |x| (end_date - x.weeks).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    end
  end
end
