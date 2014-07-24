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
  }.with_indifferent_access.freeze

  BASE_SCOPES = {
    # When joining orders to order_items, we have to make sure we running calculations
    # on distinct orders rather than multiples (by order items). The query below
    # grabs all order IDs where the order's items aren't canceled and returns a
    # distinct order set from those IDs.
    order: Order.joins("INNER JOIN (SELECT DISTINCT orders_alias2.id FROM orders orders_alias2 INNER JOIN order_items order_items_alias ON order_items_alias.order_id = orders_alias2.id AND order_items_alias.delivery_status != 'canceled') orders_alias ON orders_alias.id = orders.id"),
    order_item: OrderItem.joins(:order).where.not(orders: { market_id: TEST_MARKET_IDS }, delivery_status: "canceled"),
    payment: Payment.where.not(market_id: TEST_MARKET_IDS),
    market: Market.where.not(id: TEST_MARKET_IDS),
    organization: Organization.where.not(id: TEST_ORG_IDS),
    product: Product
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
      scope: BASE_SCOPES[:order].joins(:items),
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(SUM(order_items.unit_price * COALESCE(order_items.quantity_delivered, order_items.quantity))::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)",
      format: :currency
    },
    average_order_size: {
      title: "Average Order Size",
      scope: BASE_SCOPES[:order].joins(:items),
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(COUNT(DISTINCT order_items.id)::NUMERIC / COUNT(DISTINCT orders.id)::NUMERIC)",
      format: :decimal
    },
    total_service_fees: {
      title: "Total Service Fees",
      scope: BASE_SCOPES[:payment].where(payment_type: "service"),
      attribute: "created_at",
      calculation: :sum,
      calculation_arg: :amount,
      format: :currency
    },
    # Average LO Service Fees
    # Fees charged based on user's plan
    #
    # Payment#amount when Payment#payment_type  is "service"
    average_service_fees: {
      title: "Average Service Fees",
      scope: BASE_SCOPES[:payment].where(payment_type: "service"),
      attribute: "created_at",
      calculation: :average,
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
    # Total Delivery Fees
    # Total of order delivery fees excluding orders without a delivery fee
    #
    # Order#delivery_fees when Order#delivery_fees is present
    total_delivery_fees: {
      title: "Total Delivery Fees",
      scope: BASE_SCOPES[:order].where.not(delivery_fees: [nil, 0]),
      attribute: :placed_at,
      calculation: :sum,
      calculation_arg: :delivery_fees,
      format: :currency
    },
    # Average Delivery Fees
    # Average of order delivery fees excluding orders without a delivery fee
    #
    # Order#delivery_fees when Order#delivery_fees is present
    average_delivery_fees: {
      title: "Average Delivery Fees",
      scope: BASE_SCOPES[:order].where.not(delivery_fees: [nil, 0]),
      attribute: :placed_at,
      calculation: :average,
      calculation_arg: :delivery_fees,
      format: :currency
    },
    # Credit Card Processing Fees
    # What LO charges customers for credit card processing payments
    #
    # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
    # when Order#payment_method is "credit_card"
    credit_card_processing_fees: {
      title: "Credit Card Processing Fees",
      scope: BASE_SCOPES[:order_item].where(orders: { payment_method: "credit card" }),
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "payment_seller_fee + payment_market_fee",
      format: :currency
    },
    # ACH Processing Fees
    # What LO charges customers for credit card processing payments
    #
    # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
    # when Order#payment_method is "ach"
    ach_processing_fees: {
      title: "ACH Processing Fees",
      scope: BASE_SCOPES[:order_item].where(orders: { payment_method: "ach" }),
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "payment_seller_fee + payment_market_fee",
      format: :currency
    },
    # Total Payment Processing Fees:
    # What LO charges customers for credit card + ACH processing payments
    #
    # OrderItem#payment_seller_fee + OrderItem#payment_market_fee
    # when Order#payment_method is "credit_card" or "ach"
    total_processing_fees: {
      title: "Total Processing Fees",
      scope: BASE_SCOPES[:order_item].where(orders: { payment_method: ["credit card", "ach"] }),
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "payment_seller_fee + payment_market_fee",
      format: :currency
    },
    # Total Market Fees
    # Fees charged to a Market for payments and LO fees
    #
    # OrderItem#payment_market_fee + OrderItem#local_orbit_market_fee
    total_market_fees: {
      title: "Total Market Fees",
      scope: BASE_SCOPES[:order_item],
      attribute: "orders.placed_at",
      calculation: :sum,
      calculation_arg: "market_seller_fee",
      format: :currency
    },
    total_service_transaction_fees: {
      title: "Total Service And Transaction Fees",
      calculation: :ruby,
      calculation_arg: [:+, :total_service_fees, :total_transaction_fees],
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
    # allow_credit_cards is the admin setting which when
    # false trumps the default_allow_credit_cards setting
    credit_card_markets: {
      title: "Markets Using Credit Cards",
      scope: BASE_SCOPES[:market].where(allow_credit_cards: true, default_allow_credit_cards: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    ach_markets: {
      title: "Markets Using ACH",
      scope: BASE_SCOPES[:market].where(allow_ach: true, default_allow_ach: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    lo_payment_markets: {
      title: "Markets Using LO Payments",
      scope: BASE_SCOPES[:market].where(allow_purchase_orders: true, default_allow_purchase_orders: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    start_up_markets: {
      title: "Markets On Start Up Plan",
      scope: BASE_SCOPES[:market].joins(:plan).where(plan_id: Plan.find_by_name("Start Up")),
      attribute: "markets.created_at",
      calculation: :window,
      calculation_arg: "markets.id",
      format: :integer
    },
    grow_markets: {
      title: "Markets On Grow Plan",
      scope: BASE_SCOPES[:market].joins(:plan).where(plan_id: Plan.find_by_name("Grow")),
      attribute: "markets.created_at",
      calculation: :window,
      calculation_arg: "markets.id",
      format: :integer
    },
    automate_markets: {
      title: "Markets On Automate Plan",
      scope: BASE_SCOPES[:market].joins(:plan).where(plan_id: Plan.find_by_name("Automate")),
      attribute: "markets.created_at",
      calculation: :window,
      calculation_arg: "markets.id",
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
    # Active Users
    # All sellers + all buyers for the current period
    #
    # The query below is equivalent to the following ActiveRecord but done in a
    # single query to utilize the Relation chaining in this framework.
    # (Organization.joins(products: { order_items: :order }) +
    # Organization.joins(:orders)).uniq
    active_users: {
      title: "Active Users",
      scope: BASE_SCOPES[:organization].joins(<<-SQL
        INNER JOIN (
          SELECT DISTINCT buyer_organizations.id, buyer_orders.placed_at
          FROM organizations buyer_organizations
            INNER JOIN orders buyer_orders ON buyer_orders.organization_id = buyer_organizations.id

          UNION

          SELECT DISTINCT seller_organizations.id, seller_orders.placed_at
          FROM organizations seller_organizations
            INNER JOIN products seller_products ON seller_products.organization_id = seller_organizations.id
            INNER JOIN order_items seller_order_items ON seller_order_items.product_id = seller_products.id
            INNER JOIN orders seller_orders ON seller_orders.id = seller_order_items.order_id
        ) active_organizations ON organizations.id = active_organizations.id
      SQL
      ),
      attribute: :placed_at,
      calculation: :count,
      format: :integer
    },
    total_buyer_orders: {
      title: "Buyers Placing Orders",
      scope: BASE_SCOPES[:organization].joins(:orders),
      attribute: "orders.placed_at",
      calculation: :count,
      format: :integer
    },
    total_products: {
      title: "Total Products",
      scope: BASE_SCOPES[:product],
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_products_simple: {
      title: "Total Products Using Simple Inventory",
      scope: BASE_SCOPES[:product].where(use_simple_inventory: true),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_products_advanced: {
      title: "Total Products Using Advanced Inventory",
      scope: BASE_SCOPES[:product].where(use_simple_inventory: false),
      attribute: :created_at,
      calculation: :window,
      format: :integer
    },
    total_products_ordered: {
      title: "Total Products Ordered",
      scope: BASE_SCOPES[:product].joins(:orders),
      attribute: "orders.placed_at",
      calculation: :count,
      calculation_arg: "products.id",
      format: :integer
    },
    average_product_price: {
      title: "Average Product Price",
      scope: BASE_SCOPES[:product],
      attribute: :placed_at,
      calculation: :custom,
      calculation_arg: "(COUNT(DISTINCT products.id)::NUMERIC / AVERAGE(price.sale_price)::NUMERIC)",
      format: :decimal
    },
  }

  GROUPS = {
    financials: {
      title: "Financials",
      metrics: [
        :total_orders, :total_sales, :average_order, :average_order_size,
        :total_service_fees, :total_transaction_fees, :total_delivery_fees,
        :average_delivery_fees, :average_service_fees, :credit_card_processing_fees,
        :ach_processing_fees, :total_processing_fees, :total_market_fees,
        :total_service_transaction_fees
      ]
    },
    markets: {
      title: "Markets",
      metrics: [
        :total_markets, :live_markets, :active_markets, :credit_card_markets, :ach_markets,
        :lo_payment_markets, :start_up_markets, :grow_markets, :automate_markets
      ]
    },
    users: {
      title: "Users",
      metrics: [
        :total_organizations, :total_buyer_only, :total_sellers, :total_buyers,
        :total_buyer_orders, :active_users
      ]
    },
    products: {
      title: "Products",
      metrics: [
        :total_products, :total_products_simple, :total_products_advanced, :total_products_ordered
        # :average_product_price, :number_of_items
      ]
    }
  }.with_indifferent_access

  def initialize(groups: [], interval: "month", markets: [])
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

    @headers = headers_for_interval(interval)

    @metrics = Hash[
      groups.map do |group|
        [GROUPS[group][:title], metrics_for_group(group, interval)]
      end
    ]
  end

  def self.metrics_for(groups: [], interval: "month", markets: [])
    groups = [groups].flatten
    interval = "month" unless ["week", "month"].include?(interval)
    markets ||= []

    return nil unless groups.all? { |group| GROUPS.keys.include?(group) }

    new(groups: groups, interval: interval, markets: markets)
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

  def calculate_metric(metric, interval, apply_format = true)
    m = METRICS[metric]
    scope = m[:scope].uniq if m[:scope]

    values = if m[:calculation] == :custom
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval)
      series.group_calc(m[:calculation_arg])

    elsif m[:calculation] == :window
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval, window: true)
      values = series.group_calc("SUM(COUNT(DISTINCT(#{m[:calculation_arg] || "id"}))) OVER (ORDER BY #{series.relation.group_values[0]})")

      # we have to calculate all history when using windows so we need to only
      # return the last X values from the result set
      format_values(values, interval)

    elsif m[:calculation] == :ruby
      args = m[:calculation_arg]
      metric1 = calculate_metric(args[1], interval, false)
      metric2 = calculate_metric(args[2], interval, false)

      Hash[metric1.map do |key, value|
        [key, value.send(args[0], metric2[key])]
      end]

    else
      series = scope_for(scope: scope, attribute: m[:attribute], interval: interval)
      series.send(m[:calculation], m[:calculation_arg])
    end

    Hash[values.map { |key, value| [key, (apply_format ? format_value(value, m[:format]) : value)] }]
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
    if interval == "month"
      end_date = Date.current.beginning_of_month
      (0..5).map { |x| (end_date - x.months).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    elsif interval == "week"
      end_date = Date.current.beginning_of_week - (START_OF_WEEK == :sun ? 1 : 0).days
      (0..4).map { |x| (end_date - x.weeks).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    end
  end
end
