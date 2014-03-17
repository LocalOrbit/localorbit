require 'spec_helper'

describe CartItem do
  it "requires a cart" do
    expect(subject).to have(1).error_on(:cart)
  end

  it "requires a product" do
    expect(subject).to have(1).error_on(:product)
  end

  it "has a quantity of 0" do
    expect(subject.quantity).to eql(0)
  end

  context "default factory" do
    it "is valid" do
      expect(create(:cart_item)).to be_valid
    end
  end
end
