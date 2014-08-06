require "spec_helper"

describe "Price Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::PriceCalculations::METRICS.each { |s| s.first }
    }.not_to raise_error
  end

  it "history metrics don't bomb" do
    expect {
      Metrics::PriceHistory.history_metrics.each { |s| s.first }
    }.not_to raise_error
  end
end
