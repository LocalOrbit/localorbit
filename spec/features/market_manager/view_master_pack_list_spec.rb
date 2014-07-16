require "spec_helper"

describe "Master Pack List" do
  let!(:market)             { create(:market, :with_addresses) }
  let!(:thursdays_schedule) { create(:delivery_schedule, market: market, day: 4)}
  let!(:thursday_delivery)  { create(:delivery, delivery_schedule: thursdays_schedule, deliver_on: Date.parse("May 8, 2014"))}
  let!(:fridays_schedule)   { create(:delivery_schedule, :buyer_pickup, market: market, day: 5)}
  let!(:friday_delivery)    { create(:delivery, delivery_schedule: fridays_schedule, deliver_on: Date.parse("May 9, 2014"))}

  let!(:sellers1)           { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product1)           { create(:product, :sellable, organization: sellers1) }
  let!(:product2)           { create(:product, :sellable, organization: sellers1) }

  let!(:sellers2)           { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:product3)           { create(:product, :sellable, organization: sellers2) }

  let!(:buyer1)             { create(:organization, :buyer, :single_location, markets: [market]) }

  let!(:order1_item1)       { create(:order_item, product: product1, quantity: 2, unit_price: 3.00)}
  let!(:order1_item2)       { create(:order_item, product: product3, quantity: 5, unit_price: 3.00)}
  let!(:order1)             { create(:order, items: [order1_item1, order1_item2], delivery: thursday_delivery, market: market, organization: buyer1) }

  let!(:delivered_item)     { create(:order_item, product: product2, quantity: 8, unit_price: 3.00, delivery_status: 'delivered')}
  let!(:delivered_order)    { create(:order, items: [delivered_item], delivery: thursday_delivery, market: market, organization: buyer1) }

  let!(:order_other_item1)  { create(:order_item, product: product2, quantity: 8, unit_price: 3.00)}
  let!(:order_other)        { create(:order, items: [order_other_item1], delivery: friday_delivery, market: market, organization: buyer1) }
  

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "as a market manager" do
    let(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "single order" do
      context "delivered to the buyer" do
        before do
          switch_to_subdomain(market.subdomain)
          sign_in_as(user)
          visit admin_delivery_tools_pack_list_path(thursday_delivery)
        end

        it "shows a packing slip for the buyer" do
          expect(page).to have_content("Packing Slip")
          expect(page).to have_content("Market delivers to buyer on ")
          expect(page).to have_content("May 8, 2014 between 7:00AM and 11:00AM")
          expect(page).to have_content(order1.order_number)
          expect(page).to have_content(buyer1.name)
          expect(page).to have_content(market.name)
          expect(page).to have_content("1 of 1")

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
          switch_to_subdomain(market.subdomain)
          sign_in_as(user)
          visit admin_delivery_tools_pack_list_path(friday_delivery)
        end

        it "shows a packing slip for the buyer" do
          expect(page).to have_content("Packing Slip")
          expect(page).to have_content("Buyer picks up from market on ")
          expect(page).to have_content("May 9, 2014 between 10:00AM and 12:00PM")
          expect(page).to have_content(order_other.order_number)
          expect(page).to have_content(buyer1.name)
          expect(page).to have_content(market.name)

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
      let!(:order2_item1)       { create(:order_item, product: product2, quantity: 2, unit_price: 3.00)}
      let!(:order2)             { create(:order, items: [order2_item1], delivery: thursday_delivery, market: market, organization: buyer2) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pack_list_path(thursday_delivery)
      end

      it "shows packing slips for the buyers" do
        expect(page).to have_content(buyer1.name)
        expect(page).to have_content(buyer2.name)
        expect(page).to have_content("1 of 2")
        expect(page).to have_content("2 of 2")
      end
    end
  end
end
