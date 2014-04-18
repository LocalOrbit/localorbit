require 'spec_helper'

describe StoreOrderFees do
  let!(:user)              { create(:user) }
  let!(:market)            { create(:market, :with_address, subdomain: "ada", local_orbit_seller_fee: "1.5", local_orbit_market_fee: "1", market_seller_fee: "10", credit_card_seller_fee: "4", credit_card_market_fee: "4.5", ach_seller_fee: "2", ach_market_fee: "3", ach_fee_cap: "10") }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:delivery)          { delivery_schedule.next_delivery }
  let!(:organization)      { create(:organization, :single_location) }
  let!(:seller1)           { create(:organization, :seller, markets: [market]) }
  let!(:seller2)           { create(:organization, :seller, markets: [market]) }
  let!(:product1)          { create(:product, :sellable, organization: seller1) }
  let!(:product2)          { create(:product, :sellable, organization: seller1) }
  let!(:product3)          { create(:product, :sellable, organization: seller2) }
  let!(:price1)            { product1.prices.first.update(sale_price: 5) }
  let!(:price2)            { product2.prices.first.update(sale_price: 7) }
  let!(:price3)            { product3.prices.first.update(sale_price: 9) }
  let!(:cart)              { create(:cart, organization: organization, delivery: delivery, location: organization.locations.first, market: market) }
  let!(:cart_item1)        { create(:cart_item, cart: cart, product: product1, quantity: 20) }
  let!(:cart_item2)        { create(:cart_item, cart: cart, product: product2, quantity: 15) }
  let!(:cart_item3)        { create(:cart_item, cart: cart, product: product3, quantity: 10) }
  let(:params)            { {payment_method: "purchase order"} }

  subject do
    order = Order.create_from_cart(params, cart, user)
    order.update(payment_method: params[:payment_method])
    StoreOrderFees.perform(order_params: params, cart: cart, order: order).order.reload.items.index_by {|item| item.product_id }
  end


  context "purchase order" do
    let!(:params) { { payment_method: "purchase order", payment_note: "1234" } }

    it "captures the fees at order creation" do
      item = subject[product1.id] # 100
      expect(item.market_seller_fee).to eq(10)
      expect(item.local_orbit_seller_fee).to eq(1.5)
      expect(item.local_orbit_market_fee).to eq(1)
      expect(item.payment_seller_fee).to eq(0)
      expect(item.payment_market_fee).to eq(0)

      item = subject[product2.id] # 105
      expect(item.market_seller_fee).to eq(10.5)
      expect(item.local_orbit_seller_fee).to eq(1.58)
      expect(item.local_orbit_market_fee).to eq(1.05)
      expect(item.payment_seller_fee).to eq(0)
      expect(item.payment_market_fee).to eq(0)

      item = subject[product3.id] # 90
      expect(item.market_seller_fee).to eq(9)
      expect(item.local_orbit_seller_fee).to eq(1.35)
      expect(item.local_orbit_market_fee).to eq(0.9)
      expect(item.payment_seller_fee).to eq(0)
      expect(item.payment_market_fee).to eq(0)
    end
  end

  context "credit card" do
    # TODO: Determine the actual payment note
    let!(:params) { { payment_method: "credit card", payment_note: "ref-1234" } }

    it "captures the fees at order creation" do
      item = subject[product1.id] # 100
      expect(item.market_seller_fee).to eq(10)
      expect(item.local_orbit_seller_fee).to eq(1.5)
      expect(item.local_orbit_market_fee).to eq(1)
      expect(item.payment_seller_fee).to eq(4)
      expect(item.payment_market_fee).to eq(4.5)

      item = subject[product2.id] # 105
      expect(item.market_seller_fee).to eq(10.5)
      expect(item.local_orbit_seller_fee).to eq(1.58)
      expect(item.local_orbit_market_fee).to eq(1.05)
      expect(item.payment_seller_fee).to eq(4.2)
      expect(item.payment_market_fee).to eq(4.73)

      item = subject[product3.id] # 90
      expect(item.market_seller_fee).to eq(9)
      expect(item.local_orbit_seller_fee).to eq(1.35)
      expect(item.local_orbit_market_fee).to eq(0.9)
      expect(item.payment_seller_fee).to eq(3.6)
      expect(item.payment_market_fee).to eq(4.05)
    end
  end

  context "ach" do
    # TODO: Determine the actual payment note
    let!(:params) { { payment_method: "ach", payment_note: "ref-1234" } }

    it "captures the fees at order creation" do
      item = subject[product1.id] # 100
      expect(item.market_seller_fee).to eq(10)
      expect(item.local_orbit_seller_fee).to eq(1.5)
      expect(item.local_orbit_market_fee).to eq(1)
      expect(item.payment_seller_fee).to eq(2)
      expect(item.payment_market_fee).to eq(3)

      item = subject[product2.id] # 105
      expect(item.market_seller_fee).to eq(10.5)
      expect(item.local_orbit_seller_fee).to eq(1.58)
      expect(item.local_orbit_market_fee).to eq(1.05)
      expect(item.payment_seller_fee).to eq(2.1)
      expect(item.payment_market_fee).to eq(3.15)

      item = subject[product3.id] # 90
      expect(item.market_seller_fee).to eq(9)
      expect(item.local_orbit_seller_fee).to eq(1.35)
      expect(item.local_orbit_market_fee).to eq(0.9)
      expect(item.payment_seller_fee).to eq(1.8)
      expect(item.payment_market_fee).to eq(2.7)
    end

    context "hitting order cap" do
      let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 40) }
      let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 30) }
      let!(:cart_item3) { create(:cart_item, cart: cart, product: product3, quantity: 80) }

      it "captures the fees at order creation" do
        item = subject[product1.id] # 200
        expect(item.market_seller_fee).to eq(20)
        expect(item.local_orbit_seller_fee).to eq(3)
        expect(item.local_orbit_market_fee).to eq(2)
        expect(item.payment_seller_fee).to eq(4) # 4
        expect(item.payment_market_fee).to eq(1.77) # 6

        item = subject[product2.id] # 210
        expect(item.market_seller_fee).to eq(21)
        expect(item.local_orbit_seller_fee).to eq(3.15)
        expect(item.local_orbit_market_fee).to eq(2.1)
        expect(item.payment_seller_fee).to eq(4.2) # 4.2
        expect(item.payment_market_fee).to eq(1.86) # 6.3

        item = subject[product3.id] # 720
        expect(item.market_seller_fee).to eq(72)
        expect(item.local_orbit_seller_fee).to eq(10.8)
        expect(item.local_orbit_market_fee).to eq(7.2)
        expect(item.payment_seller_fee).to eq(10) # 14.4
        expect(item.payment_market_fee).to eq(6.37) # 21.6
      end
    end
  end
end
