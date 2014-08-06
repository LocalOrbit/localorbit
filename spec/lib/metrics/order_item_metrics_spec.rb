require "spec_helper"

describe "Order Item Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::OrderItemCalculations::METRICS.each { |s| s.first }
    }.not_to raise_error
  end
end
