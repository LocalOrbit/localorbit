require "spec_helper"

describe Metrics::OrganizationHistory do
  it "doesn't bomb" do
    expect {
      described_class.metrics.each { |s| s.first }
    }.not_to raise_error
  end
end
