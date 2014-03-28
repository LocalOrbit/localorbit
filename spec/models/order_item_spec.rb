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

  describe "self.build_from_cart_item" do
    let(:market) { create(:market) }
    let(:organization) { create(:organization) }
    let(:product) { create(:product, :sellable) }
    let(:order) { create(:order, market: market, organization: organization) }
    let(:cart_item) { create(:cart_item, product: product) }

    subject { OrderItem.build_from_cart_item(cart_item, Date.today) }

    it "captures associations" do
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

  context "product inventory" do
    let!(:lot1)          { create(:lot, number: 1, quantity: 10) }
    let!(:product)       { create(:product, :sellable, lots: [lot1]) }
    let!(:market)        { create(:market) }
    let!(:organization)  { create(:organization) }
    let!(:order)         { create(:order, market: market, organization: organization) }
    let(:deliver_on)     { Date.today }

    subject do
      order_item = OrderItem.build_from_cart_item(cart_item, deliver_on)
      order_item.order = order
      order_item.save
      order_item
    end

    context "single lot" do
      let(:cart_item) { create(:cart_item, product: product, quantity: 5) }

      it "decrements lot quantity on OrderItem creation" do
        expect(subject.lots.count).to eq(1)
        expect(subject.lots.first.quantity).to eq(5)
        expect(lot1.reload.quantity).to eq(5)
      end
    end

    context "spanning multiple lots" do
      let!(:lot2)      { create(:lot, number: 2, quantity: 10, product: product) }
      let(:cart_item) { create(:cart_item, product: product, quantity: 15) }

      it "decrements lot quantity on OrderItem creation" do
        expect(subject.lots.count).to eq(2)
        expect(subject.lots.map(&:number)).to include("1", "2")
        expect(lot1.reload.quantity).to eq(0)
        expect(lot2.reload.quantity).to eq(5)
      end
    end

    context "ignores lots that are not good yet" do
      let!(:lot2)      { create(:lot, number: 2, quantity: 10, product: product, good_from: 1.day.from_now) }
      let!(:lot3)      { create(:lot, number: 3, quantity: 10, product: product) }
      let(:cart_item) { create(:cart_item, product: product, quantity: 15) }

      it "decrements lot quantity on OrderItem creation" do
        expect(subject.lots.count).to eq(2)
        expect(subject.lots.map(&:number)).to include("1", "3")
        expect(lot1.reload.quantity).to eq(0)
        expect(lot2.reload.quantity).to eq(10)
        expect(lot3.reload.quantity).to eq(5)
      end
    end

    context "ignores lots that have expired" do
      let!(:lot2)       { create(:lot, number: 2, quantity: 10, product: product, expires_at: 1.minute.from_now) }
      let!(:lot3)       { create(:lot, number: 3, quantity: 10, product: product) }
      let(:cart_item)   { create(:cart_item, product: product, quantity: 15) }
      let(:deliver_on) { 1.hour.from_now }

      it "decrements lot quantity on OrderItem creation" do
        expect(subject.lots.count).to eq(2)
        expect(subject.lots.map(&:number)).to include("1", "3")
        expect(lot1.reload.quantity).to eq(0)
        expect(lot2.reload.quantity).to eq(10)
        expect(lot3.reload.quantity).to eq(5)
      end
    end

    context "uses oldest expiring lots first" do
      let!(:lot2)      { create(:lot, number: 2, quantity: 10, product: product, expires_at: 1.minute.from_now) }
      let!(:lot3)      { create(:lot, number: 3, quantity: 10, product: product, expires_at: 1.hour.from_now) }
      let(:cart_item) { create(:cart_item, product: product, quantity: 15) }

      it "decrements lot quantity on OrderItem creation" do
        expect(subject.lots.count).to eq(2)
        expect(subject.lots.map(&:number)).to include("2", "3")
        expect(lot1.reload.quantity).to eq(10)
        expect(lot2.reload.quantity).to eq(0)
        expect(lot3.reload.quantity).to eq(5)
      end
    end
  end
end
