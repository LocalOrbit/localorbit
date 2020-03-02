require "spec_helper"

describe "Master Pack List" do
  let!(:market)             { create(:market) }
  let!(:deleted_address)    { create(:market_address, market: market, address: "123 Main", city: "Holland", state: "MI", zip: "49423", phone: "(321) 456-3456", deleted_at: Time.parse("May 1, 2014")) }
  let!(:address)            { create(:market_address, market: market, address: "321 Main", city: "Holland", state: "MI", zip: "49423", phone: "(321) 456-3456") }
  let!(:thursdays_schedule) { create(:delivery_schedule, market: market, day: 4) }
  let!(:thursday_delivery)  { create(:delivery, delivery_schedule: thursdays_schedule, deliver_on: Date.parse("May 8, 2014")) }
  let!(:fridays_schedule)   { create(:delivery_schedule, :buyer_pickup, market: market, day: 4, seller_delivery_start: "4:45 PM", seller_delivery_end: "9:05 PM", buyer_day: 5, buyer_pickup_start: "8:30 AM", buyer_pickup_end: "10:15 AM")}
  let!(:friday_delivery)    { create(:delivery, delivery_schedule: fridays_schedule, deliver_on: Date.parse("May 8, 2014"), buyer_deliver_on: Date.parse("May 9, 2014")) }

  let!(:sellers1)           { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product1)           { create(:product, :sellable, organization: sellers1) }
  let!(:product2)           { create(:product, :sellable, organization: sellers1) }

  let!(:sellers2)           { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product3)           { create(:product, :sellable, organization: sellers2) }

  let!(:buyer1)             { create(:organization, :buyer, :single_location, markets: [market]) }
  let(:buyer1_delivery)     { {delivery_address: buyer1.locations.first.address, delivery_city: buyer1.locations.first.city, delivery_state: buyer1.locations.first.state, delivery_zip: buyer1.locations.first.zip, delivery_phone: buyer1.locations.first.phone} }

  let!(:order1_item1)       { create(:order_item, product: product1, quantity: 2, unit_price: 3.00) }
  let!(:order1_item2)       { create(:order_item, product: product3, quantity: 5, unit_price: 3.00) }
  let!(:order1)             { create(:order, buyer1_delivery.merge(items: [order1_item1, order1_item2], delivery: thursday_delivery, market: market, organization: buyer1)) }

  let!(:delivered_item)     { create(:order_item, product: product2, quantity: 8, unit_price: 3.00, delivery_status: "delivered") }
  let!(:delivered_order)    { create(:order, buyer1_delivery.merge(items: [delivered_item], delivery: thursday_delivery, market: market, organization: buyer1)) }

  let!(:order_other_item1)  { create(:order_item, product: product2, quantity: 8, unit_price: 3.00) }
  let!(:order_other)        { create(:order, buyer1_delivery.merge(items: [order_other_item1], delivery: friday_delivery, market: market, organization: buyer1)) }

  before do
    Timecop.travel("May 5, 2014")
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  context "as a market manager" do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "single order" do
      context "delivered to the buyer" do
        before do
          dte = thursday_delivery.buyer_deliver_on.strftime("%Y%m%d")
          visit admin_delivery_tools_pack_list_path(dte, market_id: market.id)
        end

        it "shows a packing slip for the buyer" do
          expect(page).to have_content("Packing Slip")
          pack_list = Dom::Admin::PackList.first
          expect(pack_list.order_number).to eq(order1.order_number)
          expect(pack_list.note).to eq("1 of 1")
          expect(pack_list.delivery_message).to eq("Market delivers to buyer on")
          expect(pack_list.upcoming_delivery_date).to eq("Thursday May 8, 2014 between 7:00AM and 11:00AM")

          buyer = pack_list.buyer
          expect(buyer.org).to eq(buyer1.name)
          expect(buyer.street).to eq(buyer1.locations.first.address)

          expect(pack_list.market.org).to eq(market.name)
          expect(pack_list.market.street).to eq("321 Main")

          line_items = Dom::Admin::PackListItem.all
          expect(line_items.count).to eql(2)

          line_item = Dom::Admin::PackListItem.find_by_name(product1.name)
          expect(line_item.quantity).to have_content(2)
          expect(line_item.seller).to have_content(sellers1.name)
          expect(line_item.total_price).to have_content("$6.00")

          line_item = Dom::Admin::PackListItem.find_by_name(product3.name)
          expect(line_item.quantity).to have_content(5)
          expect(line_item.seller).to have_content(sellers2.name)
          expect(line_item.total_price).to have_content("$15.00")

          expect(Dom::Admin::PackListItem.find_by_name(product2.name)).to be_nil
        end
      end

      context "pickup at the market" do
        before do
          dte = friday_delivery.buyer_deliver_on.strftime("%Y%m%d")
          visit admin_delivery_tools_pack_list_path(dte, market_id: market.id)
        end

        it "shows a packing slip for the buyer" do
          expect(page).to have_content("Packing Slip")

          pack_list = Dom::Admin::PackList.first
          expect(pack_list.order_number).to eq(order_other.order_number)
          expect(pack_list.note).to eq("1 of 1")
          expect(pack_list.delivery_message).to eq("Buyer picks up from market on")
          expect(pack_list.upcoming_delivery_date).to eq("Friday May 9, 2014 between 8:30AM and 10:15AM")

          buyer = pack_list.buyer
          expect(buyer.org).to eq(buyer1.name)
          expect(buyer.street).to eq(buyer1.locations.first.address)

          expect(pack_list.market.org).to eq(market.name)
          expect(pack_list.market.street).to eq("321 Main")

          line_items = Dom::Admin::PackListItem.all
          expect(line_items.count).to eql(1)

          line_item = line_items[0]
          expect(line_item.name).to have_content(product2.name)
          expect(line_item.quantity).to have_content(8)
          expect(line_item.seller).to have_content(sellers1.name)
          expect(line_item.total_price).to have_content("$24.00")
        end
      end
    end

    context "multiple orders" do
      let!(:buyer2)             { create(:organization, :buyer, :single_location, markets: [market]) }
      let(:buyer2_delivery)     { {delivery_address: buyer2.locations.first.address, delivery_city: buyer2.locations.first.city, delivery_state: buyer2.locations.first.state, delivery_zip: buyer2.locations.first.zip, delivery_phone: buyer2.locations.first.phone} }
      let!(:order2_item1)       { create(:order_item, product: product2, quantity: 2, unit_price: 3.00) }
      let!(:order2)             { create(:order, buyer2_delivery.merge(items: [order2_item1], delivery: thursday_delivery, market: market, organization: buyer2)) }

      before do
        dte = thursday_delivery.deliver_on.strftime("%Y%m%d")
        visit admin_delivery_tools_pack_list_path(dte, market_id: market.id)
      end

      it "shows packing slips for the buyers" do
        pack_lists = Dom::Admin::PackList.all

        buyers = [buyer1, buyer2]

        pack_list = pack_lists[0]
        expect(pack_list.note).to eq("1 of 2")

        buyer = pack_list.buyer
        expected = buyers.find { |b| b.name == buyer.org }
        buyers.delete(expected)
        expect(expected).to be
        expect(buyer.org).to eq(expected.name)
        expect(buyer.street).to eq(expected.locations.first.address)

        expect(pack_list.market.org).to eq(market.name)
        expect(pack_list.market.street).to eq("321 Main")

        pack_list = pack_lists[1]
        expect(pack_list.note).to eq("2 of 2")

        buyer = pack_list.buyer
        expected = buyers.find { |b| b.name == buyer.org }
        buyers.delete(expected)
        expect(expected).to be
        expect(buyer.org).to eq(expected.name)
        expect(buyer.street).to eq(expected.locations.first.address)

        expect(pack_list.market.org).to eq(market.name)
        expect(pack_list.market.street).to eq("321 Main")

        expect(buyers).to be_empty
      end
    end
  end
end
