require "spec_helper"

describe OrderTemplate do
  it "requires a name and a market" do
    template = OrderTemplate.new
    expect(template).to_not be_valid
    expect(template).to have(1).error_on(:name)
    expect(template).to have(1).error_on(:market)
  end
end
