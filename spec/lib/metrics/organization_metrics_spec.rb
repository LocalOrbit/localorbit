require "spec_helper"

describe "Organization Metrics" do
  it "standard metrics don't bomb" do
    expect {
      Metrics::OrganizationCalculations::METRICS.each { |s| s.first }
    }.not_to raise_error
  end

  it "history metrics don't bomb" do
    expect {
      Metrics::OrganizationHistory.history_metrics.each { |s| s.first }
    }.not_to raise_error
  end
end
