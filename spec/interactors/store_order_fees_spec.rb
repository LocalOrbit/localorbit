require "spec_helper"

describe StoreOrderFees do
  let!(:user)              { create(:user, :buyer) }
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
  let(:payment_provider) { PaymentProvider::Stripe.id }

  subject do
    order = CreateOrder.perform(payment_provider: payment_provider, order_params: params, cart: cart, buyer: user).order
    order.update(payment_method: params[:payment_method])
    StoreOrderFees.perform(payment_provider: payment_provider, order_params: params, cart: cart, order: order).order.reload.items.index_by {|item| item.product_id }
  end

  context "discounts" do
    it "applys the market discount before figuring out the fees" do
      order_item = create(:order_item, product: product1, quantity: 10, discount_market: 1.00)
      discounted_order = create(:order, market: market, items: [order_item])

      StoreOrderFees.perform(payment_provider: payment_provider, order_params: params, cart: cart, order: discounted_order).order.reload.items.index_by {|item| item.product_id }

      item = discounted_order.items.first # 69.90
      expect(item.market_seller_fee.to_f).to eq(6.99)
      expect(item.local_orbit_seller_fee.to_f).to eq(1.03)
      expect(item.local_orbit_market_fee.to_f).to eq(0.69)
      expect(item.payment_seller_fee.to_f).to eq(0)
      expect(item.payment_market_fee.to_f).to eq(0)
    end

    it "applys the seller discount before figuring out the fees" do
      order_item = create(:order_item, product: product1, quantity: 10, discount_seller: 1.00)
      discounted_order = create(:order, market: market, items: [order_item])

      StoreOrderFees.perform(payment_provider: payment_provider, order_params: params, cart: cart, order: discounted_order).order.reload.items.index_by {|item| item.product_id }

      item = discounted_order.items.first # 69.90
      expect(item.market_seller_fee.to_f).to eq(6.89)
      expect(item.local_orbit_seller_fee.to_f).to eq(1.03)
      expect(item.local_orbit_market_fee.to_f).to eq(0.69)
      expect(item.payment_seller_fee.to_f).to eq(0)
      expect(item.payment_market_fee.to_f).to eq(0)
    end
  end

  context "purchase order" do
    let!(:params) { {payment_method: "purchase order", payment_note: "1234"} }

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
    let!(:params) { {payment_method: "credit card", payment_note: "ref-1234"} }

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

end
