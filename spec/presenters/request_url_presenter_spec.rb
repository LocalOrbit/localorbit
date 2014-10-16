require 'spec_helper'

describe RequestUrlPresenter do
  let(:request) { double("Request", base_url: "the base url") }
  subject { described_class.new(request) }

  describe "#base_url" do
    it "mirrors Request#base_url" do
      expect(subject.base_url).to eq(request.base_url)
    end
  end

  it "can be dumped and reloaded via YAML" do
    dumped = YAML.dump(subject)
    expect(dumped).to be
    
    other = YAML.load(dumped)
    expect(other).to be
    expect(other.base_url).to eq(subject.base_url)
  end
end
