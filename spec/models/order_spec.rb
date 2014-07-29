require 'spec_helper'

describe Order do
  context "validations" do
    it "requires an organization id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:organization_id)
    end

    it "requires a market id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:market_id)
    end

    it "requires a delivery id" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_id)
    end

    it "requires a order number" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:order_number)
    end

    it "requires a placed_at date" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:placed_at)
    end

    it "requires delivery fees" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_fees)
    end

    it "requires a total cost" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:total_cost)
    end

    it "requires a delivery address" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_address)
    end

    it "requires a delivery city" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_city)
    end

    it "requires a delivery state" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_state)
    end

    it "requires a delivery zip" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:delivery_zip)
    end

    it "requires a billing organization name" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_organization_name)
    end

    it "requires a billing address" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_address)
    end

    it "requires a billing city" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_city)
    end

    it "requires a billing state" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_state)
    end

    it "requires a billing zip" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:billing_zip)
    end


    it "requires a payment status" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:payment_status)
    end

    it "requires a payment method" do
      expect(subject).to be_invalid
      expect(subject).to have(1).error_on(:payment_method)
    end
  end

  context "payment status updated" do
    let!(:market)       { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
    let!(:delivery)    { delivery_schedule.next_delivery }
    let!(:organization) { create(:organization, markets: [market]) }

    let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }

    it "updates order items if they are unpaid" do
      order.update(payment_status: 'paid')

      order.reload.items.each do |i|
        expect(i.payment_status).to eql('paid')
      end
    end

    it "sets payment_status to 'refunded' if all items have been refunded" do
      order.items.each {|i| i.update(payment_status: 'refunded')}
      order.save!

      expect(order.reload.payment_status).to eql("refunded")
    end
  end

  describe ".orders_for_buyer" do
    context "admin" do
      let(:market)       { create(:market) }
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:delivery)    { delivery_schedule.next_delivery }

      let(:organization) { create(:organization, markets: [market]) }
      let!(:user)        { create(:user, :admin) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it "returns all orders" do
        orders = Order.orders_for_buyer(user)

        expect(orders).to eq(Order.all)
      end
    end

    context "market manager" do
      let!(:user)        { create(:user, :market_manager) }
      let(:market)       { user.managed_markets.first }
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:delivery)    { delivery_schedule.next_delivery }

      let(:other_market) { create(:market) }
      let(:organization) { create(:organization, markets: [market]) }
      let(:org2)         { create(:organization, markets: [other_market], users: [user])}
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }
      let!(:other_market_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: other_market) }
      let!(:valid_other_market_order) { create(:order, :with_items, delivery: delivery, organization: org2, market: other_market) }

      it "returns only managed markets orders" do
        orders = Order.orders_for_buyer(user)

        expect(orders.count).to eq(3)
        expect(orders).to include(order, other_order, valid_other_market_order)
      end
    end

    context "user" do
      let(:market)       { create(:market) }
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:delivery)    { delivery_schedule.next_delivery }
      let(:organization) { create(:organization, markets: [market]) }
      let!(:user)        { create(:user, organizations:[organization]) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it 'returns only the organizations orders' do
        orders = Order.orders_for_buyer(user)

        expect(orders.count).to eq(1)
        expect(orders).to include(order)
      end
    end
  end

  describe "destruction" do
    let(:market)       { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
    let!(:delivery)    { delivery_schedule.next_delivery }
    let(:organization) { create(:organization, markets: [market]) }
    let!(:user)        { create(:user, organizations:[organization]) }
    let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }

    it 'removes order items' do
      expect {
        order.destroy
      }.to change {
        OrderItem.count
      }.from(1).to(0)
    end
  end

  describe ".orders_for_seller" do
    context "admin" do
      let(:market)       { create(:market) }
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:delivery)    { delivery_schedule.next_delivery }
      let(:organization) { create(:organization, markets: [market]) }
      let!(:user)        { create(:user, :admin) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it "returns all orders" do
        orders = Order.orders_for_seller(user)

        expect(orders).to eq(Order.all)
      end
    end

    context "market_manager" do
      let!(:user)    { create(:user, :market_manager) }
      let!(:market1) { user.managed_markets.first }
      let!(:delivery_schedule) { create(:delivery_schedule) }
      let!(:delivery)    { delivery_schedule.next_delivery }

      let!(:market2) { create(:market) }
      let!(:org1)    { create(:organization, users: [user], markets: [market2]) }
      let!(:org2)    { create(:organization, markets: [market2]) }
      let!(:product1) { create(:product, :sellable, organization: org1) }
      let!(:product2) { create(:product, :sellable, organization: org2) }
      let!(:product3) { create(:product, :sellable, organization: org1) }

      let!(:managed_order) { create(:order, market: market1, delivery: delivery, organization_id: 0, items: [create(:order_item, product: product2)]) }
      let!(:org_order)     { create(:order, market: market2, delivery: delivery, organization_id: 0, items: [create(:order_item, product: product1),create(:order_item, product: product3)]) }
      let!(:not_order)     { create(:order, market: market2, delivery: delivery, organization_id: 0, items: [create(:order_item, product: product2)]) }

      it "returns only managed markets orders" do
        orders = Order.orders_for_seller(user)

        expect(orders.count).to eq(2)
        expect(orders).to include(managed_order, org_order)
      end
    end

    context "seller" do
      let(:market)       { create(:market) }
      let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
      let!(:delivery)    { delivery_schedule.next_delivery }
      let(:organization) { create(:organization, markets: [market]) }
      let(:product)      { create(:product, :sellable, organization: organization)}
      let(:product2)     { create(:product, :sellable, organization: organization)}
      let!(:user)        { create(:user, organizations:[organization]) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:order_item)  { create(:order_item, order: order, product: product) }
      let!(:order_item2) { create(:order_item, order: order, product: product2) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it 'returns only the organizations orders' do
        orders = Order.orders_for_seller(user)

        expect(orders.count).to eq(1)
        expect(orders).to include(order)
      end
    end
  end

  describe "self.create_from_cart" do
    let(:buyer)             { create(:user) }
    let(:market)            { create(:market, subdomain: "ada") }
    let(:delivery_location) { create(:location) }
    let(:pickup_location)   { create(:market_address, market: market) }
    let(:delivery_schedule) { create(:delivery_schedule) }
    let(:delivery)          { delivery_schedule.next_delivery }
    let(:organization)      { create(:organization, :single_location) }
    let(:billing_address)   { organization.locations.default_billing }
    let(:cart)              { create(:cart, :with_items, organization: organization, delivery: delivery, location: delivery_location, market: market) }
    let(:params)            { { payment_method: "purchase order"} }

    subject { Order.create_from_cart(params, cart, buyer) }

    context "purchase order" do
      let(:params) { { payment_method: "purchase order", payment_note: "1234" } }

      it "sets the payment type" do
        expect(subject.payment_method).to eql("purchase order")
      end

      it "sets the payment note" do
        expect(subject.payment_note).to eql("1234")
      end
    end

    context "when the order is invalid", truncate: true do
      let(:params) { { payment_method: nil, payment_note: "1234" } }

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
      subject { expect{ Order.create_from_cart(params, cart, create(:user)) }.to raise_exception }

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

  describe "#delivered_at" do
    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    subject{ create(:order, delivery: delivery, items: items) }
    let(:items) { create_list(:order_item, 2, product: create(:product, :sellable)) }

    def set_delivered(item, date)
      Timecop.freeze(date) do
        item.delivery_status = "delivered"
        item.save!
      end
    end

    context "no delivered order items" do
      it "returns nil" do
        expect(subject.delivered_at).to be_nil
      end
    end

    context "some delivered order items" do
      let(:delivered_at) { 1.week.ago }

      before do
        set_delivered(items.first, delivered_at)
      end

      it "returns nil" do
        expect(subject.delivered_at).to be_nil
      end
    end

    context "all delivered order items" do
      let!(:delivery_schedule) { create(:delivery_schedule) }
      let!(:delivery)    { delivery_schedule.next_delivery }

      let(:delivered_at) { Time.current - 1.week }
      let(:latest_delivered_at) { Time.current - 2.days}
      let(:items) { create_list(:order_item, 2, product: create(:product, :sellable)) }

      before do
        set_delivered(items[0], delivered_at)
        set_delivered(items[1], latest_delivered_at)
      end

      it "returns the delivered_at date of the last order item delivered" do
        expect(subject.delivered_at).not_to be_nil
        expect(subject.delivered_at.to_i).to eq(items[1].delivered_at.to_i)
      end
    end
  end

  describe "#paid_at" do
    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    subject{ create(:order, delivery: delivery, items: items) }
    let(:items) { create_list(:order_item, 2, product: create(:product, :sellable)) }

    def set_payment_status(item, date)
      Timecop.freeze(date) do
        item.payment_status = "paid"
        item.save!
      end
    end

    context "setting payment_status to 'paid'" do
      it "saves the time the order was paid for" do
        time = Time.zone.parse("Januray 4, 2014")
        expect(subject.paid_at).to be_nil

        Timecop.freeze(time) do
          subject.payment_status = "paid"
          subject.save!
        end

        subject.reload
        expect(subject.paid_at).to eql(time)
      end
    end
  end

  describe "#sellers" do
    context "no order items" do
      it "returns an empty array" do
        order = build(:order)
        expect(order.sellers).to eql([])
      end
    end

    context "with order_items" do
      let!(:delivery_schedule) { create(:delivery_schedule) }
      let!(:delivery)    { delivery_schedule.next_delivery }

      let(:ada_farms) { create(:organization, :seller) }
      let(:fulton_farms) { create(:organization, :seller) }
      let(:not_included_farms) { create(:organization, :seller) }


      let(:kale) { create(:product, :sellable, organization: ada_farms) }
      let(:bananas) { create(:product, :sellable, organization: ada_farms) }
      let(:peas) { create(:product, :sellable, organization: fulton_farms) }
      let!(:tomatoes) { create(:product, :sellable, organization: not_included_farms) }

      it "returns sellers involved in order" do
        order_items = [
          create(:order_item, product: kale),
          create(:order_item, product: bananas),
          create(:order_item, product: peas)
        ]

        order = create(:order, delivery: delivery, items: order_items)

        expect(order.sellers.count).to eql(2)
        expect(order.sellers).to include(ada_farms)
        expect(order.sellers).to include(fulton_farms)
        expect(order.sellers).not_to include(not_included_farms)
      end
    end
  end

  describe ".delivered" do
    let(:product) { create(:product, :sellable) }
    let(:product2) { create(:product, :sellable) }

    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    let(:delivered_item1) { create(:order_item, product: product, delivery_status: "delivered") }
    let(:delivered_item2) { create(:order_item, product: product2, delivery_status: "delivered") }
    let!(:delivered_order) { create(:order, delivery: delivery, items: [delivered_item1, delivered_item2]) }

    let(:undelivered_item1) { create(:order_item, product: product) }
    let(:undelivered_item2) { create(:order_item, product: product2) }
    let!(:undelivered_order) { create(:order, delivery: delivery, items: [undelivered_item1, undelivered_item2]) }

    it "returns orders where all items have deivered" do
      expect(Order.joins(:items).delivered).to include(delivered_order)
      expect(Order.joins(:items).delivered).not_to include(undelivered_order)
    end
  end

  describe "#update_total_cost" do
    let(:market)       { create(:market) }
    let!(:delivery_schedule) { create(:delivery_schedule, fee: "1.75", fee_type: "fixed") }
    let!(:delivery)    { delivery_schedule.next_delivery }
    let(:organization) { create(:organization, markets: [market]) }
    let!(:user)        { create(:user, :admin) }
    let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
    let!(:order_item)  { order.items.first }

    it "updates the total cost on order save" do
      expect(order.total_cost.to_f).to eql(8.74)

      order_item.update(unit_price: 3.99)
      order.save!

      expect(order.reload.total_cost.to_f).to eql(5.74)
    end

    it "does not include fixed delivery fees if the subtotal is zero" do
      expect(order.total_cost.to_f).to eql(8.74)

      order_item.update(quantity: 0)
      order.save!

      expect(order.reload.total_cost.to_f).to eql(0.0)
    end
  end

  describe "payable to market" do
    let(:order_item1) { build(:order_item, delivery_status: "pending",   unit_price: "12.23", quantity: 1, market_seller_fee: "2.10", local_orbit_seller_fee: "3.20", local_orbit_market_fee: "2.40", payment_seller_fee: "1.30", payment_market_fee: "0.20") }
    let(:order_item2) { build(:order_item, delivery_status: "canceled",  unit_price: "17.13", quantity: 2, market_seller_fee: "0.00", local_orbit_seller_fee: "0.00", local_orbit_market_fee: "0.00", payment_seller_fee: "0.00", payment_market_fee: "0.00") }
    let(:order_item3) { build(:order_item, delivery_status: "delivered", unit_price: "13.27", quantity: 4, market_seller_fee: "3.87", local_orbit_seller_fee: "4.39", local_orbit_market_fee: "3.76", payment_seller_fee: "2.32", payment_market_fee: "1.30") }
    let(:order_item4) { build(:order_item, delivery_status: "contested", unit_price: "14.75", quantity: 2, market_seller_fee: "1.56", local_orbit_seller_fee: "2.80", local_orbit_market_fee: "3.10", payment_seller_fee: "2.10", payment_market_fee: "1.50") }
    let(:order_item5) { build(:order_item, delivery_status: "delivered", unit_price: "10.83", quantity: 3, market_seller_fee: "2.87", local_orbit_seller_fee: "3.39", local_orbit_market_fee: "2.76", payment_seller_fee: "1.32", payment_market_fee: "0.30") }
    let(:order) { build(:order, delivery_fees: "11", total_cost: "138.30", items: [order_item1, order_item2, order_item3, order_item4, order_item5]) }

    it "payable_to_market returns the appropriate value" do
      # delivered item subtotal + delivery fee - local orbit fees - payment fees
      expect(order.payable_to_market.to_s).to eq("77.03")
    end

    it "payable_subtotal" do
      # delivery fee + delivered item gross total
      expect(order.payable_subtotal.to_s).to eq("96.57")
    end

    it "market_payable_market_fee" do
      expect(order.market_payable_market_fee.to_s).to eq("6.74")
    end

    it "market_payable_local_orbit_fee" do
      expect(order.market_payable_local_orbit_fee.to_s).to eq("14.3")
    end

    it "market_payable_payment_fee" do
      expect(order.market_payable_payment_fee.to_s).to eq("5.24")
    end
  end
end
