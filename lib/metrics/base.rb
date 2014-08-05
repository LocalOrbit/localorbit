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

    # Called from the metrics rake tasks to calculate history for the given subclass
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
  end
end

# Because dev environment does eager loading, we need to manually
# load these classes or they won't appear in dev or test mode.
require_dependency "metrics/market_calculations"
