namespace :metrics do
  desc "calculates Market metrics for the previous day"
  task market: [:environment] do
    before = Metric.where(model_type: "Market").count
    Metrics::MarketHistory.perform
    count = Metric.where(model_type: "Market").count - before

    puts "#{count} Market #{"metric".pluralize(count)} changed since the last run." 
  end

  desc "calculates Organization metrics for the previous day"
  task organization: [:environment] do
    before = Metric.where(model_type: "Organization").count
    Metrics::OrganizationHistory.perform
    count = Metric.where(model_type: "Organization").count - before

    puts "#{count} Organization #{"metric".pluralize(count)} changed since the last run."
  end

  desc "calculates Product metrics for the previous day"
  task product: [:environment] do
    before = Metric.where(model_type: "Product").count
    Metrics::ProductHistory.perform
    count = Metric.where(model_type: "Product").count - before

    puts "#{count} Product #{"metric".pluralize(count)} changed since the last run."
  end
end
