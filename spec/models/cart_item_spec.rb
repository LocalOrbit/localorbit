require "spec_helper"

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

  it "can not have more then 2 Trillion" do
    subject.quantity = 2_147_483_647

    expect(subject).to have(1).error_on(:quantity)
  end

  context "default factory" do
    it "is valid" do
      expect(create(:cart_item)).to be_valid
    end
  end

  context "quantity is greater than the available product" do
    let(:product) { create(:product, :sellable, name: "Bananas") } # lot w/ quantity 150

    subject { build(:cart_item, product: product, quantity: 151) }

    it "has an error" do
      expect(subject).to have(1).error_on(:quantity)
    end
  end

  context "quantity is nil" do
    let(:product) { create(:product, :sellable, name: "Bananas") } # lot w/ quantity 150

    subject { build(:cart_item, product: product, quantity: nil) }

    it "has an error" do
      expect(subject).to have(1).error_on(:quantity)
    end
  end

  describe "#unit" do
    let(:product) { create(:product, :sellable, name: "Bananas") } # lot w/ quantity 150
    let(:cart_item) { create(:cart_item, product: product) }

    it "returns the singular unit for a quantity of 1" do
      cart_item.quantity = 1

      expect(cart_item.unit).to eql(product.unit.singular)
    end

    it "returns the plural unit for a quantity greater than 1" do
      cart_item.quantity = 2

      expect(cart_item.unit).to eql(product.unit.plural)
    end

    it "returns the plural unit for a quantity of 0" do
      cart_item.quantity = 0

      expect(cart_item.unit).to eql(product.unit.plural)
    end
  end
end
