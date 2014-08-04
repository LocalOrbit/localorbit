require "spec_helper"

describe "Product Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::ProductCalculations.metrics.each { |s| s.first }
    }.not_to raise_error
  end

  it "history metrics don't bomb" do
    expect {
      Metrics::ProductHistory.history_metrics.each { |s| s.first }
    }.not_to raise_error
  end
end
