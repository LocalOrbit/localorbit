require "spec_helper"

describe MetricsPresenter do
  it "metrics don't bomb" do
    expect {
      described_class::METRICS.each_pair do |metric, hash|
        # percent_growth and ruby metrics don't have base scopes
        hash[:scope].first if ![:percent_growth, :ruby].include? hash[:calculation]
      end
    }.not_to raise_error
  end
end
