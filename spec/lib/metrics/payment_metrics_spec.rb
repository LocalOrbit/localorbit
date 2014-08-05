require "spec_helper"

describe "Payment Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::PaymentCalculations::METRICS.each { |s| s.first }
    }.not_to raise_error
  end
end
