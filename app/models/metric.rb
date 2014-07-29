class Metric < ActiveRecord::Base
  store_accessor :metrics_data, Metrics::Market::METRICS.keys

  belongs_to :model, polymorphic: true
end
