require "spec_helper"

describe CreateOrder do
  let(:buyer)             { create(:user) }
  let(:market)            { create(:market, subdomain: "ada") }
  let(:delivery_location) { create(:location) }
  let(:pickup_location)   { create(:market_address, market: market) }
  let(:delivery_schedule) { create(:delivery_schedule) }
  let(:delivery)          { delivery_schedule.next_delivery }
  let(:organization)      { create(:organization, :single_location) }
  let(:billing_address)   { organization.locations.default_billing }
  let(:cart)              { create(:cart, :with_items, organization: organization, delivery: delivery, location: delivery_location, market: market) }
  let(:params)            { {payment_method: "purchase order"} }

  subject { CreateOrder.perform(order_params: params, cart: cart, buyer: buyer).order }

  context "purchase order" do
    let(:params) { {payment_method: "purchase order", payment_note: "1234"} }

    it "sets the payment type" do
      expect(subject.payment_method).to eql("purchase order")
    end

    it "sets the payment note" do
      expect(subject.payment_note).to eql("1234")
    end
  end

  context "when the order is invalid", truncate: true do
    let(:params) { {payment_method: nil, payment_note: "1234"} }

    it "will not consume inventory" do
      expect {
        subject
      }.not_to change{
        cart.items.map{|item| Lot.find_by(product_id: item.product.id).quantity }
      }
    end
  end

  context "when an exception occurs when creating cart items", truncate: true do
    let(:problem_product) { cart.items[1].product }
    subject { expect { CreateOrder.perform(order_params: params, cart: cart, buyer: buyer) }.to raise_exception }

    before do
      expect(problem_product).to receive(:lots_by_expiration).and_raise
    end

    it "will not create OrderItems" do
      expect {
        subject
      }.not_to change {
        OrderItem.count
      }
    end

    it "will not consume inventory" do
      expect {
        subject
      }.not_to change {
        cart.items.map{|item| Lot.find_by(product_id: item.product.id).quantity }
      }
    end
  end

  it "assigns the cart references" do
    expect(subject.organization).to eql(cart.organization)
    expect(subject.market).to eql(cart.market)
    expect(subject.delivery).to eql(cart.delivery)
  end

  context "delivery information" do
    let!(:admin) { create(:user, :admin) }
    context "for dropoff" do
      let(:delivery_schedule) { create(:delivery_schedule, :buyer_pickup) }
      it "captures location" do
        expect(subject.delivery_address).to eql(pickup_location.address)
        expect(subject.delivery_city).to eql(pickup_location.city)
        expect(subject.delivery_state).to eql(pickup_location.state)
        expect(subject.delivery_zip).to eql(pickup_location.zip)
        expect(subject.delivery_phone).to eql(pickup_location.phone)
        expect(subject.delivery_status_for_user(admin)).to eql("pending")
      end
    end

    context "for delivery" do
      it "captures location" do
        expect(subject.delivery_address).to eql(delivery_location.address)
        expect(subject.delivery_city).to eql(delivery_location.city)
        expect(subject.delivery_state).to eql(delivery_location.state)
        expect(subject.delivery_zip).to eql(delivery_location.zip)
        expect(subject.delivery_phone).to eql(delivery_location.phone)
        expect(subject.delivery_status_for_user(admin)).to eql("pending")
      end
    end
  end

  it "captures billing information" do
    expect(subject.billing_organization_name).to eql(organization.name)
    expect(subject.billing_address).to eql(billing_address.address)
    expect(subject.billing_city).to eql(billing_address.city)
    expect(subject.billing_state).to eql(billing_address.state)
    expect(subject.billing_zip).to eql(billing_address.zip)
    expect(subject.billing_phone).to eql(billing_address.phone)
  end

  it "captures payment information" do
    expect(subject.payment_status).to eql("unpaid")
  end

  it "captures order items" do
    expect(subject.items.count).to eql(cart.items.count)
  end

  # TODO: is this the same as created_at?  REMOVE IT!
  it "captures the placed at time" do
    expect(subject.placed_at).to_not be_nil
  end

  it "captures the delivery fees" do
    expect(subject.delivery_fees).to eql(cart.delivery_fees)
  end

  it "captures the total cost" do
    expect(subject.total_cost).to eql(cart.total)
  end

  describe "#subtotal" do
    it "calculates the sum of the gross totals for all items" do
      expect(subject.subtotal.to_f).to eql(6.0)
    end
  end

  it "has an order number sequential to the market" do
    Timecop.freeze(Date.parse("2014-03-01"))
    expect(subject.order_number).to eq("LO-14-ADA-0000001")
    Timecop.return
  end

  it "saves the user" do
    expect(subject.placed_by).to eql(buyer)
  end

end
