require "spec_helper"

describe "Order Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::OrderCalculations::METRICS.each { |s| s.first }
    }.not_to raise_error
  end
end
