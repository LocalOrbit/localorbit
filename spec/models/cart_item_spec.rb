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


  context "quantity is greater than the available product" do
    let(:product) { create(:product, :sellable, name: "Bananas") } # lot w/ quantity 15

    subject { build(:cart_item, product: product, quantity: 16) }

    it "has an error" do
      expect(subject).to have(1).error_on(:quantity)
    end
  end
end
