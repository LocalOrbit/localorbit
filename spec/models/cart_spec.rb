require 'spec_helper'

describe Cart do

  it "requires an organization" do
    expect(subject).to have(1).error_on(:organization)
  end

  it "requires a market" do
    expect(subject).to have(1).error_on(:market)
  end

  it "requires a delivery" do
    expect(subject).to have(1).error_on(:delivery)
  end

  it "has no items" do
    expect(subject.items).to be_empty
  end

  describe "default factory" do
    subject { create(:cart) }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

end
