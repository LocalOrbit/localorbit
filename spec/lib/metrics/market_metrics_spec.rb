require "spec_helper"

describe "Market Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::MarketCalculations.metrics.each { |s| s.first }
    }.not_to raise_error
  end

  it "history metrics don't bomb" do
    expect {
      Metrics::MarketHistory.history_metrics.each { |s| s.first }
    }.not_to raise_error
  end
end
