module Metrics
  class Base
    def self.perform
      self.metrics.each do |metric, scope|
        model_ids = scope.where("#{scope.table_name}.created_at <= ?", 1.day.ago.end_of_day).pluck(:id)
        metric = Metric.find_or_initialize_by(metric_code: metric, effective_on: 1.day.ago, model_type: self.model_name)
        if metric.model_ids.to_set != model_ids.to_set
          metric.model_ids = model_ids
          metric.save!
        end
      end
    end
  end
end
