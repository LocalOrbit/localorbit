require "spec_helper"

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
      order.update(payment_status: "paid")

      order.reload.items.each do |i|
        expect(i.payment_status).to eql("paid")
      end
    end

    it "sets payment_status to 'refunded' if all items have been refunded" do
      order.items.each {|i| i.update(payment_status: "refunded") }
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
      let(:org2)         { create(:organization, markets: [other_market], users: [user]) }
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
      let!(:user)        { create(:user, organizations: [organization]) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it "returns only the organizations orders" do
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
    let!(:user)        { create(:user, organizations: [organization]) }
    let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }

    it "removes order items" do
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
      let!(:org_order)     { create(:order, market: market2, delivery: delivery, organization_id: 0, items: [create(:order_item, product: product1), create(:order_item, product: product3)]) }
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
      let(:product)      { create(:product, :sellable, organization: organization) }
      let(:product2)     { create(:product, :sellable, organization: organization) }
      let!(:user)        { create(:user, organizations: [organization]) }
      let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market) }
      let!(:order_item)  { create(:order_item, order: order, product: product) }
      let!(:order_item2) { create(:order_item, order: order, product: product2) }
      let!(:other_order) { create(:order, :with_items, delivery: delivery, organization_id: 0, market: market) }

      it "returns only the organizations orders" do
        orders = Order.orders_for_seller(user)

        expect(orders.count).to eq(1)
        expect(orders).to include(order)
      end
    end
  end

  describe "#delivered_at" do
    let!(:delivery_schedule) { create(:delivery_schedule) }
    let!(:delivery)    { delivery_schedule.next_delivery }

    subject { create(:order, delivery: delivery, items: items) }
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
      let(:latest_delivered_at) { Time.current - 2.days }
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

    subject { create(:order, delivery: delivery, items: items) }
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

  describe "#sellers_with_changes" do
    let!(:market)          { create(:market) }

    let!(:seller1)         { create(:organization, :seller, markets: [market]) }
    let!(:seller1_product) { create(:product, :sellable, organization: seller1) }
    let!(:seller2)         { create(:organization, :seller, markets: [market]) }
    let!(:seller2_product) { create(:product, :sellable, organization: seller2) }
    let!(:seller3)         { create(:organization, :seller, markets: [market]) }
    let!(:seller3_product) { create(:product, :sellable, organization: seller3) }

    let!(:order_item1)     { create(:order_item, product: seller1_product, quantity: 2) }
    let!(:order_item2)     { create(:order_item, product: seller2_product, quantity: 2) }
    let!(:order_item3)     { create(:order_item, product: seller3_product, quantity: 2) }
    let!(:order)           { create(:order, items: [order_item1, order_item2, order_item3]) }

    let!(:update_params)   do
      {
        updated_at: Time.current,
        items_attributes: {
          "0" => {
            id: order_item1.id,
            quantity: 4
          },
          "1" => {
            id: order_item2.id,
            quantity_delivered: 4
          },
          "2" => {
            id: order_item3.id,
            quantity: 0
            #_destroy: "true"
          }
        }
      }
    end

    before do
      Order.enable_auditing
      OrderItem.enable_auditing
      order.reload.update(update_params)
      OrderItem.disable_auditing
      Order.disable_auditing

      Audit.all.update_all(request_uuid: SecureRandom.uuid)
    end

    it "returns sellers where the item quantity has changed" do
      sellers_with_change = order.reload.sellers_with_changes

      expect(sellers_with_change).to eql([seller1])
    end

    it "returns sellers where the item has been deleted" do
      sellers_with_remove = order.reload.sellers_with_cancel

      expect(sellers_with_remove).to eql([seller3])
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
    let!(:order)       { create(:order, :with_items, delivery: delivery, organization: organization, market: market, delivery_fees: 1.75, total_cost: 8.74) }
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

    it "takes credits into account" do
      credit = create(:credit, order: order, user: user, amount: 1.00)
      expect(order.reload.total_cost.to_f).to eql(7.74)
      credit.amount = 50
      credit.amount_type = Credit::PERCENTAGE
      credit.save
      expect(order.reload.total_cost.to_f).to eql(5.24)
    end

    it "does not use invalid credits" do
      credit = create(:credit, order: order, user: user, amount: 1.00)
      order.credit = credit
      order.payment_method = "credit card"
      order.save
      expect(order.reload.total_cost.to_f).to eql(8.74)
    end
  end

  describe "payable to market" do
    let(:order_item1) { create(:order_item, delivery_status: "pending",   unit_price: "12.23", quantity: 1, market_seller_fee: "2.10", local_orbit_seller_fee: "3.20", local_orbit_market_fee: "2.40", payment_seller_fee: "1.30", payment_market_fee: "0.20") }
    let(:order_item2) { create(:order_item, delivery_status: "canceled",  unit_price: "17.13", quantity: 2, market_seller_fee: "0.00", local_orbit_seller_fee: "0.00", local_orbit_market_fee: "0.00", payment_seller_fee: "0.00", payment_market_fee: "0.00") }
    let(:order_item3) { create(:order_item, delivery_status: "delivered", unit_price: "13.27", quantity: 4, market_seller_fee: "3.87", local_orbit_seller_fee: "4.39", local_orbit_market_fee: "3.76", payment_seller_fee: "2.32", payment_market_fee: "1.30", discount_market: 5.00) }
    let(:order_item4) { create(:order_item, delivery_status: "contested", unit_price: "14.75", quantity: 2, market_seller_fee: "1.56", local_orbit_seller_fee: "2.80", local_orbit_market_fee: "3.10", payment_seller_fee: "2.10", payment_market_fee: "1.50") }
    let(:order_item5) { create(:order_item, delivery_status: "delivered", unit_price: "10.83", quantity: 3, market_seller_fee: "2.87", local_orbit_seller_fee: "3.39", local_orbit_market_fee: "2.76", payment_seller_fee: "1.32", payment_market_fee: "0.30", discount_market: 5.00) }
    let(:order) { create(:order, delivery_fees: "11", total_cost: "138.30", items: [order_item1, order_item2, order_item3, order_item4, order_item5]) }

    context "no discount" do
      it "payable_to_market returns the appropriate value" do
        # delivered item subtotal + delivery fee - local orbit fees - payment fees - discount amount paid by market
        expect(order.payable_to_market.to_s).to eq("67.03")
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

    context "with discount" do
      let!(:discount) { create(:discount, type: "fixed", payer: "market", discount: 10.00) }
      let!(:order) { create(:order, delivery_fees: "11", total_cost: "138.30", items: [order_item1, order_item2, order_item3, order_item4, order_item5], discount: discount) }

      it "payable_to_market returns the appropriate value" do
        # delivered item subtotal + delivery fee - local orbit fees - payment fees - discount
        expect(order.payable_to_market.to_s).to eq("67.03")
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

  describe "soft_delete" do
    include_context "soft delete-able models"
    it_behaves_like "a soft deleted model"
  end

  describe ".payable scope" do
    #              -48 ago                         NOW
    # ---------------|------------------------------|
    # o1             |
    # o2.do o2.bdo   |
    #       o3.bdo   |  o3.do
    #                |  o4
    let(:now) { Time.current }
    let(:forty_nine_hours_ago) { now - 49.hours }
    let(:forty_seven_hours_ago) { now - 47.hours }
    let(:three_days_ago) { now - 3.days }

    let!(:order1) { create_order_with_delivery_times(both: forty_nine_hours_ago) }
    let!(:order2) { create_order_with_delivery_times(deliver_on: three_days_ago, buyer_deliver_on: forty_nine_hours_ago) }
    let!(:order3) { create_order_with_delivery_times(deliver_on: forty_seven_hours_ago, buyer_deliver_on: forty_nine_hours_ago) }
    let!(:order4) { create_order_with_delivery_times(deliver_on: forty_seven_hours_ago, buyer_deliver_on: forty_seven_hours_ago) }

    it "includes all orders" do
      expect(Order.payable).to contain_exactly(order1, order2, order3, order4)
    end

    def create_order_with_delivery_times(both:nil,buyer_deliver_on: nil, deliver_on: nil)
      if (deliver_on and buyer_deliver_on) or both
        deliver_on ||= both
        buyer_deliver_on ||= both
        delivery = create(:delivery, deliver_on: deliver_on, buyer_deliver_on: buyer_deliver_on)
        create(:order, delivery: delivery)
      else
        raise "Alternatives: provide :both, or both :deliver_on AND :buyer_deliver_on"
      end
    end
  end

  describe ".on_automate_plan scope" do
    let(:m1) { Generate.market_with_orders(plan: :grow) }
    let(:m2) { Generate.market_with_orders(plan: :automate) }

    it "returns orders only for markets on the Automate plan" do
      expect(Order.on_automate_plan).to contain_exactly(*m2[:orders])
    end

  end

  describe ".payable and .payable_to_sellers" do
    let(:order_time) { Time.zone.parse("May 20, 2014 2:00 PM") }
    let(:deliver_time) { Time.zone.parse("May 25, 2014 3:30 PM") }
    let(:now_time) { Time.zone.parse("May 30, 2014 1:15 AM") }


    let!(:m1) { Generate.market_with_orders(
                  order_time: order_time,
                  deliver_time: deliver_time,
                  paid_with: "credit card",
                  delivered: "delivered",
    )}

    let(:expected_order_ids) { m1[:orders].map(&:id) }

    describe ".payable_to_sellers and .payable_to_automate_sellers" do
      def payable_order_ids(*args)
        Order.payable_to_sellers(*args).map(&:id)
      end

      def payable_automate_order_ids(*args)
        Order.payable_to_automate_sellers(*args).map(&:id)
      end

      it "filters results based on optional seller id" do
        # NOTE: Being lazy. The assumptions about the seller and order(s) involved are coincidental based
        # on assumed knowledge of how Generate.market_with_orders creates data. (This isn't the same as order-of-insertion reliance  on the db, but almost as naughty.)
        # I just happen to know that function creates Orders and Sellers in tandem, 1 apiece given the above params.
        # Upshot: be thoughtful when updating this stuff.
        seller_id = m1[:seller_organizations].first # the first seller ...
        seller_order_ids = [ m1[:orders].first.id ] # ...will correspond to the first order
        expect(payable_order_ids(current_time: now_time, seller_organization_id: seller_id)).to contain_exactly(*seller_order_ids)
        expect(payable_automate_order_ids(current_time: now_time, seller_organization_id: seller_id)).to contain_exactly(*seller_order_ids)

        seller_id = m1[:seller_organizations].last # the last seller...
        seller_order_ids = [ m1[:orders].last.id ] # ...will correspond to the last order
        expect(payable_order_ids(current_time: now_time, seller_organization_id: seller_id)).to contain_exactly(*seller_order_ids)
        expect(payable_automate_order_ids(current_time: now_time, seller_organization_id: seller_id)).to contain_exactly(*seller_order_ids)
      end

      describe "when some orders have market payments" do
        # Setup a market payment...
        let(:market_payment1) { create(:payment, :market_orders, payee: m1[:market]) }

        before do
          # Link the market payment to the last order in our working set:
          m1[:orders].last.payments << market_payment1
        end

        it ".payable_to_sellers still includes orders w market payments" do
          expect(payable_order_ids(current_time: deliver_time+2.days+1.hour)).to contain_exactly(*expected_order_ids)
        end

        it ".payable_to_automate_sellers EXCLUDES orders which have market orders" do
          less_orders = expected_order_ids[0..-2] # we associated a market payment with m1[:orders].last, so let's not expect the last order id
          expect(payable_automate_order_ids(current_time: deliver_time+2.days+1.hour)).to contain_exactly(*less_orders)
        end


      end
    end
  end

  describe "payment provider scopes" do
    let!(:balanced_orders) { create_list(:order, 3, payment_provider: PaymentProvider::Balanced.id.to_s) }
    let!(:stripe_orders) { create_list(:order, 2, payment_provider: PaymentProvider::Stripe.id.to_s) }
    let!(:other_orders) { create_list(:order, 2, payment_provider: "something else") }

    it ".balanced keeps only Balanced orders" do
      expect(Order.balanced.to_set).to eq balanced_orders.to_set
    end

    it ".not_balanced keeps any NON-Balanced orders" do
      expect(Order.not_balanced.to_set).to eq (stripe_orders.to_set + other_orders.to_set)
    end

    it ".stripe keeps only Stripe orders" do
      expect(Order.stripe.to_set).to eq stripe_orders.to_set
    end

    it ".not_stripe keeps any NON-Stripe orders" do
      expect(Order.not_stripe.to_set).to eq (balanced_orders.to_set + other_orders.to_set)
    end
  end

  describe ".stripe and .not_stripe scopes" do
    let!(:balanced_orders) { create_list(:order, 3, payment_provider: PaymentProvider::Balanced.id.to_s) }
    let!(:stripe_orders) { create_list(:order, 2, payment_provider: PaymentProvider::Stripe.id.to_s) }
    # let!(:other_orders) { create_list(:order, 2, payment_provider: nil) }

    it "only returns orders orders whose payment_provider is set to balanced" do
      expect(Order.balanced.to_set).to eq balanced_orders.to_set
    end

    it "can be negated" do
      expect(Order.not_balanced.to_set).to eq stripe_orders.to_set
    end
  end

end
