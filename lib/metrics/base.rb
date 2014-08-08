module Metrics
  class Base
    METRICS = {}

    TEST_MARKET_IDS = Market.where(demo: true).pluck(:id)
    TEST_ORG_IDS    = Market.where(id: TEST_MARKET_IDS).joins(:organizations).uniq.pluck("organizations.id")

    def self.register_metrics(metrics)
      METRICS.merge!(metrics)
    end

    # History
    # =======

    # called from the metrics rake tasks to calculate history for the given subclass
    def self.perform
      self.history_metrics.each do |metric_code, metric_params|
        if [:count, :sum].include? metric_params[:calculation]
          scope  = metric_params[:scope]
          scope  = scope.group(metric_params[:group]) if metric_params[:group]
          scope  = scope.joins(metric_params[:joins]) if metric_params[:joins]
          values = scope.send(metric_params[:calculation], metric_params[:calculation_arg])

          if metric_params[:group]
            history_custom_group(metric_params, metric_code, values)
          else
            history_custom(metric_params, metric_code, values)
          end
        else
          history_metric(metric_params, metric_code)
        end
      end
    end

    def self.history_custom_group(metric_params, metric_code, values)
      values.each_pair do |model_id, value|
        metric = Metric.where(metric_code: metric_code,
                              effective_on: Date.current,
                              model_type: metric_params[:model_type]).
                        where("'?' = ALL(model_ids)", model_id).first
        metric ||= Metric.new(metric_code: metric_code,
                              effective_on: Date.current,
                              model_type: metric_params[:model_type],
                              model_ids: [model_id])

        metric.update!(value: value)
      end
    end

    def self.history_custom(metric_params, metric_code, value)
      metric = Metric.find_or_initialize_by(metric_code: metric_code,
                                            effective_on: Date.current,
                                            model_type: self.model_name)

      metric.update!(value: value)
    end

    def self.history_metric(metric_params, metric_code)
      model_ids = metric_params[:scope].pluck(:id)
      metric = Metric.find_or_initialize_by(metric_code: metric_code,
                                            effective_on: Date.current,
                                            model_type: self.model_name)

      # we don't to trigger an update if only the order of IDs changed so we
      # cast the arrays to sets to ensure uniqueness
      metric.update!(model_ids: model_ids) if metric.model_ids.to_set != model_ids.to_set
    end

    # Current
    # =======

    def self.calculate_metric(metric:, interval:, markets: [], options:)
      m = METRICS[metric]

      if m[:scope]
        scope = m[:scope].uniq

        unless markets.empty?
          if scope.table_name == "metrics"
            # overlap is from postres_ext gem is an array operator that matches
            # records where the array field (model_ids) includes one or more value
            # from the operand (markets)
            scope = scope.where.overlap(model_ids: markets)
          else
            scope = scope.where(markets: {id: markets})
          end
        end
      end

      values = case m[:calculation]
        when :custom
          calculate_custom(scope: scope, metric: m, interval: interval, options: options)
        when :ruby
          calculate_ruby(scope: scope, metric: m, interval: interval, markets: markets, options: options)
        when :percent_growth
          calculate_percent_growth(metric: m, interval: interval, markets: markets, options: options)
        when :metric
          calculate_metric_history(scope: scope, metric_code: metric, interval: interval, options: options)
        else
          calculate_standard(scope: scope, metric: m, interval: interval, options: options)
      end

      Hash[values.map {|key, value| [key, value] }]
    end

    def self.calculate_custom(scope:, metric:, interval:, options:)
      series = scope_for(scope: scope, attribute: metric[:attribute], interval: interval, options: options)
      series.group_calc(metric[:calculation_arg])
    end

    def self.calculate_ruby(scope:, metric:, interval:, markets: [], options:)
      args = metric[:calculation_arg]
      metric1 = calculate_metric(metric: args[1],
                                 interval: interval,
                                 markets: markets,
                                 options: options)
      metric2 = calculate_metric(metric: args[2],
                                 interval: interval,
                                 markets: markets,
                                 options: options)

      Hash[metric1.map do |key, value|
        [key, (value.send(args[0], metric2[key]) rescue 0)]
      end]
    end

    def self.calculate_percent_growth(metric:, interval:, markets: [], options:)
      base_metric = calculate_metric(metric: metric[:calculation_arg],
                                     interval: interval,
                                     markets: markets,
                                     options: options).to_a
      growth_metric = {}

      base_metric.each_with_index do |value, index|
        if index <= 0
          growth_metric[value[0]] = nil
        else
          growth_metric[value[0]] = ((value[1].to_f - base_metric[index - 1][1].to_f) / base_metric[index - 1][1].to_f) * 100
        end
      end

      growth_metric
    end

    def self.calculate_metric_history(scope:, metric_code:, interval:, options:)
      model_name = scope.name
      sub_select = Metric.where(model_type: model_name, metric_code: metric_code).
                          select(:effective_on, "UNNEST(model_ids) AS model_id").
                          where(effective_on: options[:range])

      scope = scope.
        joins("INNER JOIN (#{sub_select.to_sql}) AS metric_calculation ON metric_calculation.model_id = #{model_name.pluralize.downcase}.id").
        select("metric_calculation.effective_on, metric_calculation.model_id")

      scope_for(scope: scope, attribute: "metric_calculation.effective_on", interval: interval, options: options).
        count("DISTINCT(model_id)")
    end

    def self.calculate_standard(scope:, metric:, interval:, options:)
      series = scope_for(scope: scope, attribute: metric[:attribute], interval: interval, options: options)
      series.send(metric[:calculation], metric[:calculation_arg])
    end

    def self.scope_for(scope:, attribute:, interval:, options:)
      group_options = options.dup
      groupdate = group_options.delete(:groupdate)

      scope.send(groupdate, attribute, group_options)
    end
  end
end

# Because dev environment does eager loading, we need to manually
# load these classes or they won't appear in dev or test mode.
require_dependency "metrics/market_calculations"
require_dependency "metrics/order_calculations"
require_dependency "metrics/order_item_calculations"
require_dependency "metrics/organization_calculations"
require_dependency "metrics/payment_calculations"
require_dependency "metrics/price_calculations"
require_dependency "metrics/product_calculations"
