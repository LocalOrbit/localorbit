require 'spec_helper'

describe StoreOrderFees do
  let(:market)            { create(:market, subdomain: "ada") }
  let(:delivery_location) { create(:location) }
  let(:pickup_location)   { create(:market_address, market: market) }
  let(:delivery_schedule) { create(:delivery_schedule) }
  let(:delivery)          { delivery_schedule.next_delivery }
  let(:organization)      { create(:organization, :single_location) }
  let(:billing_address)   { organization.locations.default_billing }
  let(:cart)              { create(:cart, :with_items, organization: organization, delivery: delivery, location: delivery_location, market: market) }
  let(:params)            { { payment_method: "purchase order"} }

  subject { StoreOrderFees.perform(order_params: params, cart: cart, order: Order.create_from_cart(params, cart)).order.reload }

  context "purchase order" do
    let(:params) { { payment_method: "purchase order", payment_note: "1234" } }

    it "captures the fees at order creation" do
      item = subject.items.first
      expect(item.market_seller_fee).to eq(0.03)
      expect(item.local_orbit_seller_fee).to eq(0.06)
      expect(item.local_orbit_market_fee).to eq(0)
      expect(item.payment_seller_fee).to eq(0)
      expect(item.payment_market_fee).to eq(0)
    end
  end

  context "credit card" do
    # TODO: Determine the actual payment note
    let(:params) { { payment_method: "credit card", payment_note: "ref-1234" } }

    it "captures the fees at order creation" do
      item = subject.items.first
      expect(item.market_seller_fee).to eq(0.03)
      expect(item.local_orbit_seller_fee).to eq(0.06)
      expect(item.local_orbit_market_fee).to eq(0)
      expect(item.payment_seller_fee).to eq(0.09)
      expect(item.payment_market_fee).to eq(0)
    end
  end

  context "ach" do
    # TODO: Determine the actual payment note
    let(:params) { { payment_method: "ach", payment_note: "ref-1234" } }

    it "captures the fees at order creation" do
      item = subject.items(true).first
      expect(item.market_seller_fee).to eq(0.03)
      expect(item.local_orbit_seller_fee).to eq(0.06)
      expect(item.local_orbit_market_fee).to eq(0)
      expect(item.payment_seller_fee).to eq(0.04)
      expect(item.payment_market_fee).to eq(0)
    end

    context "hitting order cap" do
      let(:market) { create(:market, subdomain: "ada", ach_seller_fee: 2, ach_market_fee: 4) }

      before do
        @item1, @item2 = cart.items
        @item1.quantity = 500
        @item1.save
        @item2.quantity = 750
        @item2.save
      end

      it "captures the fees at order creation" do
        item = subject.items(true).where(product_id: @item1.product_id).first
        expect(item.market_seller_fee).to eq(15)
        expect(item.local_orbit_seller_fee).to eq(30)
        expect(item.local_orbit_market_fee).to eq(0)
        expect(item.payment_seller_fee).to eq(1.07) # 30
        expect(item.payment_market_fee).to eq(2.13) # 60

        item = subject.items.where(product_id: @item2.product_id).first
        expect(item.market_seller_fee).to eq(22.5)
        expect(item.local_orbit_seller_fee).to eq(45)
        expect(item.local_orbit_market_fee).to eq(0)
        expect(item.payment_seller_fee).to eq(1.6) # 45
        expect(item.payment_market_fee).to eq(3.2) # 90
      end
    end
  end
end
