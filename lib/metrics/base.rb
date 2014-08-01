module Metrics
  class Base
    def self.perform
      self.metrics.each do |metric_code, m|
        if [:count, :sum].include? m[:calculation]
          scope = m[:scope].where("#{m[:scope].table_name}.created_at <= ?", 1.day.ago.end_of_day)
          scope = scope.group(m[:group]) if m[:group]
          scope = scope.joins(m[:joins]) if m[:joins]
          values = scope.send(m[:calculation], m[:calculation_arg])

          if m[:group]
            values.each_pair do |model_id, value|
              metric = Metric.where(metric_code: metric_code, effective_on: 1.day.ago, model_type: m[:model_type]).where("'?' = ALL(model_ids)", model_id).first
              metric ||= Metric.new(metric_code: metric_code, effective_on: 1.day.ago, model_type: m[:model_type], model_ids: [model_id])

              if metric.value != value
                metric.value = value
                metric.save!
              end
            end
          else
            metric = Metric.find_or_initialize_by(metric_code: metric_code, effective_on: 1.day.ago, model_type: self.model_name)

            if metric.value != values
              metric.value = values
              metric.save!
            end
          end
        else
          model_ids = m[:scope].where("#{m[:scope].table_name}.created_at <= ?", 1.day.ago.end_of_day).pluck(:id)
          metric = Metric.find_or_initialize_by(metric_code: metric_code, effective_on: 1.day.ago, model_type: self.model_name)

          if metric.model_ids.to_set != model_ids.to_set
            metric.model_ids = model_ids
            metric.save!
          end
        end
      end
    end
  end
end
