class MetricsPresenter
  include ActiveSupport::NumberHelper

  attr_reader :metrics, :headers, :markets

  START_OF_WEEK = :sun

  DEFAULT_INTERVAL_COUNT = {
    week: 5,
    month: 8,
    day: 30
  }

  GROUPDATE_OPTIONS = {
    week: {
      caption: "Week",
      groupdate: :group_by_week,
      format: "%-m/%-d/%Y"
    },
    month: {
      caption: "Month",
      groupdate: :group_by_month,
      format: "%b %Y"
    },
    day: {
      caption: "Day",
      groupdate: :group_by_day,
      format: "%b %-d"
    }
  }.with_indifferent_access.freeze

  GROUPS = {
    financials: {
      title: "Financials",
      metrics: [
        :total_orders, :total_orders_percent_growth, :total_sales, :total_sales_percent_growth,
        :average_order, :average_order_size, :total_service_fees, :total_service_fees_percent_growth,
        :total_transaction_fees, :total_transaction_fees_percent_growth,
        :total_delivery_fees, :total_delivery_fees_percent_growth,
        :average_delivery_fees, :average_service_fees, :average_service_fees_percent_growth,
        :credit_card_processing_fees, :credit_card_processing_fees_percent_growth,
        :ach_processing_fees, :ach_processing_fees_percent_growth, :total_processing_fees,
        :total_processing_fees_percent_growth, :total_market_fees, :total_market_fees_percent_growth,
        :total_service_transaction_fees, :total_service_transaction_fees_percent_growth
      ]
    },
    markets: {
      title: "Markets",
      metrics: [
        :total_markets, :live_markets, :live_markets_percent_growth, :active_markets,
        :active_markets_percent_growth, :credit_card_markets, :credit_card_markets_percent_growth,
        :ach_markets, :ach_markets_percent_growth, :lo_payment_markets,
        :lo_payment_markets_percent_growth, :start_up_markets, :start_up_markets_percent_growth,
        :grow_markets, :grow_markets_percent_growth, :automate_markets, :automate_markets_percent_growth
      ]
    },
    users: {
      title: "Users",
      metrics: [
        :total_organizations, :total_buyer_only, :total_sellers, :total_sellers_percent_growth,
        :total_buyers, :total_buyers_percent_growth, :total_buyer_orders,
        :total_buyer_orders_percent_growth, :active_users
      ]
    },
    products: {
      title: "Products",
      metrics: [
        :total_products, :total_products_simple, :total_products_advanced, :total_products_ordered,
        :average_price
      ]
    }
  }.with_indifferent_access

  def initialize(groups: [], interval: "month", markets: [], date_range: nil)
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

    @date_range = date_range

    # @headers = headers_for_interval(interval)

    if groups.include?("financials") || groups.include?("products")
      @markets = Market.where.not(id: Metrics::Base::TEST_MARKET_IDS).order("LOWER(name)").pluck(:id, :name)
    end

    @metrics = Hash[
      groups.map do |group|
        [GROUPS[group][:title], metrics_for_group(group, interval, markets)]
      end
    ]
  end

  def self.metrics_for(groups: [], interval: "month", markets: [], start_date: nil, end_date: nil)
    groups = [groups].flatten
    interval = "month" unless GROUPDATE_OPTIONS.keys.include?(interval)
    markets = [markets].compact.flatten.delete_if(&:empty?)
    date_range = self.create_or_expand_date_range(interval: interval, start_date: start_date, end_date: end_date)

    return nil unless groups.all? {|group| GROUPS.keys.include?(group) }

    new(groups: groups, interval: interval, markets: markets, date_range: date_range)
  end

  def start_date
    @date_range.begin if @date_range
  end

  def end_date
    @date_range.end if @date_range
  end

  private

  def self.create_or_expand_date_range(interval:, start_date: nil, end_date: nil)
    end_date = case interval
                 when "day"
                   end_date || Date.current
                 when "week"
                   (end_date || Date.current).end_of_week
                 when "month"
                   (end_date || Date.current).end_of_month
                end
    start_date = case interval
                  when "day"
                    start_date || end_date - DEFAULT_INTERVAL_COUNT[:day].days
                  when "week"
                    (start_date || end_date - DEFAULT_INTERVAL_COUNT[:week].weeks).beginning_of_week
                  when "month"
                    (start_date || end_date - DEFAULT_INTERVAL_COUNT[:month].months).beginning_of_month
                 end

    Range.new(start_date, end_date)
  end

  def metrics_for_group(group, interval, markets=[])
    Hash[GROUPS[group][:metrics].map do |metric|
      m = Metrics::Base::METRICS[metric]

      calculation_options = GROUPDATE_OPTIONS[interval].dup.merge({ range: @date_range })
      results = Metrics::Base.calculate_metric(metric: metric,
                                               interval: interval,
                                               markets: markets,
                                               options: calculation_options,
                                               date_range: @date_range)

      results = format_results(results: results, interval: interval, calculation_type: m[:calculation], format: m[:format])

      [m[:title], results]
    end]

  end

  def format_results(results:, interval:, calculation_type:, format:)
    @headers = results.keys
    if calculation_type == :window
      Hash[@headers.map { |header| [header, format_value(value: (results[header] || results.values.last || 0), format: format)] }.last(@headers.count)]
    else
      Hash[@headers.map { |header| [header, format_value(value: results[header], format: format)] }]
    end
  end

  def format_value(value:, format:)
    case format
    when :integer  then (value || 0).to_i
    when :decimal  then (value || 0).try(:round, 2)
    when :currency then number_to_currency(value || 0)
    when :percent
      if value.try(:infinite?)
        "∞"
      elsif value = (value.try(:nan?) ? 0 : value)
        sprintf("%+0.1f%%", value)
      else
        nil
      end
    else value
    end
  end

  # Cast to format - precompile these again
  def headers_for_interval(interval)
    if interval == "month"
      end_date = Date.current.beginning_of_month
      (0...GROUPDATE_OPTIONS[:month][:last]).map {|x| (end_date - x.months).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    elsif interval == "week"
      end_date = Date.current.beginning_of_week - (START_OF_WEEK == :sun ? 1 : 0).days
      (0...GROUPDATE_OPTIONS[:week][:last]).map {|x| (end_date - x.weeks).strftime(GROUPDATE_OPTIONS[interval][:format]) }.reverse
    end
  end
end
