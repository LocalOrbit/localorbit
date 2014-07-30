module Metrics
  class Base
    def self.perform
      self.metrics.keys.each do |metric|
        model_ids = self.metrics[metric].where("#{self.model_name.pluralize.downcase}.created_at <= ?", 1.day.ago.end_of_day).pluck(:id)

        Metric.create!(metric_code: metric, effective_on: 1.day.ago, model_type: self.model_name, model_ids: model_ids)
      end
    end
  end
end
