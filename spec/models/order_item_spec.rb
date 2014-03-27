require 'spec_helper'

describe OrderItem do
  context "validations" do
    it "requires a order" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:order)
    end

    it "requires a name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:name)
    end

    it "requires a seller name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:seller_name)
    end

    it "requires a unit" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:unit)
    end

    it "requires a unit_price" do
      subject.unit_price = nil
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:unit_price)
    end

    it "requires a quantity" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:quantity)
    end
  end

  describe "self.create_from_cart_item_for_order" do
    let(:market) { create(:market) }
    let(:organization) { create(:organization) }
    let(:product) { create(:product, :sellable) }
    let(:order) { create(:order, market: market, organization: organization) }
    let(:cart_item) { create(:cart_item, product: product) }

    subject { OrderItem.create_from_cart_item_for_order(cart_item, order)}

    it "captures associations" do
      expect(subject.order).to eql(order)
      expect(subject.product).to eql(product)
    end

    it "captures the product name" do
      expect(subject.name).to eq(product.name)
    end

    it "captures the seller name" do
      expect(subject.seller_name).to eql(product.organization.name)
    end

    it "captures the unit" do
      expect(subject.quantity).to eql(1)
      expect(subject.unit).to eql(product.unit.singular)
    end

    it "captures the unit price" do
      expect(subject.unit_price).to eql(cart_item.unit_price.sale_price)
    end

    it "captures the quantity" do
      expect(subject.quantity).to eql(cart_item.quantity)
    end
  end
end
