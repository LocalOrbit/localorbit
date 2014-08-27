require "spec_helper"

describe StickyFilters do
  include StickyFilters

  let(:session) { {} }
  let(:request) { double(:request) }

  before do
    allow(request).to receive(:path) { @path }
    @path = "/test"
  end

  it "returns given parameters on first request" do
    params = {"foo" => "bar"}
    expect(sticky_parameters(params)).to eq(params)
  end

  it "returns new and saved parameters on subsequent requests" do
    sticky_parameters("foo" => "bar")
    expect(sticky_parameters("boo" => "hiss")).to eq("foo" => "bar", "boo" => "hiss")
  end

  it "saves params per path" do
    sticky_parameters("foo" => "bar")
    @path = "/something"
    expect(sticky_parameters("boo" => "hiss")).to eq("boo" => "hiss")
  end

  it "saves params per path ignoring format" do
    sticky_parameters("foo" => "bar")
    @path = "/something.csv"
    expect(sticky_parameters("boo" => "hiss")).to eq("boo" => "hiss")
  end

  it "replaces saved parameter if given a new value in a request" do
    sticky_parameters("foo" => "bar", "boo" => "hiss")
    expect(sticky_parameters("boo" => "ya!")).to eq("foo" => "bar", "boo" => "ya!")
  end

  it "removes parameters when given a blank value, deeply" do
    sticky_parameters("foo" => "bar", "boo" => "hiss", "q" => {"glass" => "vase", "grass" => "lawn"})
    expect(sticky_parameters("foo" => "", "q" => {"glass" => ""})).to eq("boo" => "hiss", "q" => {"grass" => "lawn"})
  end

  it "clears all parameters when 'clear' parameter is present execpt per_page" do
    expect(sticky_parameters("foo" => "bar", "clear" => "", "per_page" => "11")).to eq("per_page" => "11")
  end

  it "clears only parameters for the page when 'clear' parameters is present" do
    sticky_parameters("foo" => "bar")
    @path = "/something"
    sticky_parameters("boo" => "hiss")
    expect(sticky_parameters("clear" => "")).to eq({})
    @path = "/test"
    expect(sticky_parameters({})).to eq("foo" => "bar")
  end
end
