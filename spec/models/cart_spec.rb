require "spec_helper"

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

  describe "#delivery_fees" do
    let(:delivery_schedule) { create(:delivery_schedule) }
    let(:delivery) { delivery_schedule.next_delivery }
    let(:cart) { create(:cart, delivery: delivery) }
    let!(:product1) { create(:product, :sellable) }
    let!(:product2) { create(:product, :sellable) }
    # 1 item at $3.00
    let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 1) }
    # 1 item at $3.00
    let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 1) }

    context "no delivery fee" do
      it "returns $0.00" do
        expect(cart.delivery_fees).to eq(0.0)
      end

      it "returns 0 if fixed fee is nil" do
        delivery_schedule.fee_type = "fixed"
        delivery_schedule.save

        expect(cart.delivery_fees).to eq(0.0)
      end

      it "returns 0 if percentage fee is nil" do
        delivery_schedule.fee_type = "percent"
        delivery_schedule.save

        expect(cart.delivery_fees).to eq(0.0)
      end
    end

    context "percentage" do
      let(:delivery_schedule) { create(:delivery_schedule, :percent_fee) }

      it "returns $1.50" do
        expect(cart.delivery_fees).to eq(1.50)
      end

      it "returns 0 if fee is nil" do
        delivery_schedule.fee = nil

        expect(cart.delivery_fees).to eq(0)
      end
    end

    context "dollar amount" do
      let(:delivery_schedule) { create(:delivery_schedule, :fixed_fee) }

      it "returns $1.00" do
        expect(cart.delivery_fees).to eq(1.00)
      end
    end
  end

  describe "#total" do
    let(:delivery_schedule) { create(:delivery_schedule) }
    let(:delivery) { delivery_schedule.next_delivery }
    let(:cart) { create(:cart, delivery: delivery) }
    let!(:product1) { create(:product, :sellable) }
    let!(:product2) { create(:product, :sellable) }
    # 1 item at $3.00
    let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 1) }
    # 1 item at $3.00
    let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 1) }
    context "without delivery fees" do
      it "returns the subtotal" do
        expect(cart.total).to eql(6.0)
      end
    end

    context "with delivery fees" do
      context "fixe fee" do
        let(:delivery_schedule) { create(:delivery_schedule, :fixed_fee) }
        it "returns the subtotal plus delivery fees" do
          expect(cart.total).to eql(7.0)
        end
      end

      context "percent fee" do
        let(:delivery_schedule) { create(:delivery_schedule, :percent_fee) }
        it "returns the subtotal plus delivery fees" do
          expect(cart.total).to eql(7.50)
        end
      end
    end
  end
end
