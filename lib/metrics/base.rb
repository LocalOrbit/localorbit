module Metrics
  class Base
    attr_accessor :base_scope, :metrics, :model_name

    def self.perform
      self.new.perform
    end

    def initialize(base_scope:, metrics:, model_name:)
      @base_scope = base_scope
      @metrics    = metrics
      @model_name = model_name
    end

    def perform
      metrics = Hash[@metrics.keys.map { |metric| [metric, calculate_metric(metric)] }]
      market_ids = metrics.values.flatten.uniq

      metrics_attributes = calculate_metrics(@model_name, market_ids, metrics)

      metrics_attributes.each do |metric_hash|
        perform_change_capture(metric_hash)
      end
    end

    def calculate_metric(metric)
      @metrics[metric].where("#{@model_name.pluralize.downcase}.created_at <= ?", 1.day.ago.end_of_day).pluck(:id)
    end

    def calculate_metrics(model_type, ids, metrics)
      ids.map do |id|
        metric_hash = { model_type: model_type, model_id: id, metrics_data: {} }

        @metrics.keys.each do |metric|
          metric_hash[:metrics_data][metric] = 1 if metrics[metric].include?(id)
        end

        metric_hash
      end
    end

    def perform_change_capture(metric_hash)
      old_metric = ::Metric.where(model_type: metric_hash[:model_type], expire_on: "9999-12-31").find_by(model_id: metric_hash[:model_id])
      new_metric = ::Metric.new(metric_hash.merge({ effective_on: "1900-01-01", expire_on: "9999-12-31" }))

      if old_metric
        if old_metric.metrics_data != new_metric.metrics_data
          # If there is already a metric for 1.day.ago, it will fail due to DB
          # contraint. If that happens, we can swallow the exception.
          old_metric.try(:update_attribute, :expire_on, 1.day.ago)

          new_metric.effective_on = 1.day.ago
          new_metric.save
        end
      else
        new_metric.save
      end
    end
  end
end
