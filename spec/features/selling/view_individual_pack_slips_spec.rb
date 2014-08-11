require "spec_helper"

describe "Individual pack slips" do
  let!(:market)  { create(:market, :with_addresses) }
  let!(:sellers) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:others) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:sellers_product) { create(:product, :sellable, organization: sellers) }
  let!(:sellers_delivered_product) { create(:product, :sellable, organization: sellers) }
  let!(:others_product) { create(:product, :sellable, organization: others) }

  let!(:buyer1) { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:buyer2) { create(:organization, :buyer, :single_location, markets: [market]) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "for buyer pickup" do
    let!(:friday_schedule_schedule) { create(:delivery_schedule, :buyer_pickup, market: market, day: 5) }
    let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

    let!(:sellers_order_item) { create(:order_item, product: sellers_product, quantity: 1)}
    let!(:sellers_delivered_order_item) { create(:order_item, product: sellers_product, quantity: 1, delivery_status: "delivered")}
    let!(:sellers_order)      { create(:order, items:[sellers_order_item, sellers_delivered_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

    let!(:others_order_item) { create(:order_item, product: others_product, quantity: 2)}
    let!(:others_order)      { create(:order, items: [others_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

    context "as a market manager" do
      let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_individual_pack_list_path(friday_delivery.id)
      end

      it "shows a packing slip for the seller to the buyer" do
        expect(page).to have_content("Individual Packing Slips")
        expect(page).to have_content("Seller Delivers to Market on")
        expect(page).to have_content("Friday May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content("For pick up on Friday May 9, 2014 between 10:00AM and 12:00PM")

        expect(Dom::Admin::IndividualPackListItem.count).to eql(2)

        line = Dom::Admin::IndividualPackListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content(1)
        expect(line.units).to have_content(sellers_product.unit.singular)

        line = Dom::Admin::IndividualPackListItem.find_by_name(others_product.name)
        expect(line.total_sold).to have_content(2)
        expect(line.units).to have_content(others_product.unit.singular)
      end
    end

    context "as a seller" do
      let!(:user) { create(:user, organizations: [sellers]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_individual_pack_list_path(friday_delivery.id)
      end

      it "shows a packing slip for the seller to the buyer" do
        expect(page).to have_content("Individual Packing Slips")
        expect(page).to have_content("Seller Delivers to Market on")
        expect(page).to have_content("Friday May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content("For pick up on Friday May 9, 2014 between 10:00AM and 12:00PM")

        expect(page).to have_content(sellers_order.order_number)

        expect(page).to have_content(sellers.name)
        expect(page).to have_content(buyer1.name)

        expect(Dom::Admin::IndividualPackListItem.count).to eql(1)

        line = Dom::Admin::IndividualPackListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content(1)
        expect(line.units).to have_content(sellers_product.unit.singular)
      end

      it "does not show slips for a different seller" do
        expect(page).to have_content("Individual Packing Slips")

        expect(page).to_not have_content(others_order.order_number)

        expect(page).to_not have_content(others.name)
        expect(page).to_not have_content(buyer2.name)
      end
    end
  end

  context "dropoff to customer" do
    let!(:friday_schedule_schedule) { create(:delivery_schedule, market: market, day: 5) }
    let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

    let!(:sellers_order_item) { create(:order_item, product: sellers_product, quantity: 1)}
    let!(:sellers_order)      { create(:order, items:[sellers_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

    let!(:others_order_item) { create(:order_item, product: others_product, quantity: 2)}
    let!(:others_order)      { create(:order, items: [others_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

    context "as a market manager" do
      let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_individual_pack_list_path(friday_delivery.id)
      end

      it "shows a packing slip for the seller to the buyer" do
        expect(page).to have_content("Individual Packing Slips")
        expect(page).to have_content("Seller Delivers to Customer on")
        expect(page).to have_content("Friday May 9, 2014 between 7:00AM and 11:00AM")

        expect(Dom::Admin::IndividualPackListItem.count).to eql(2)

        line = Dom::Admin::IndividualPackListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content(1)
        expect(line.units).to have_content(sellers_product.unit.singular)

        line = Dom::Admin::IndividualPackListItem.find_by_name(others_product.name)
        expect(line.total_sold).to have_content(2)
        expect(line.units).to have_content(others_product.unit.singular)
      end
    end

    context "as a seller" do
      let!(:user) { create(:user, organizations: [sellers]) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_individual_pack_list_path(friday_delivery.id)
      end

      it "shows a packing slip for the seller to the buyer" do
        expect(page).to have_content("Individual Packing Slips")
        expect(page).to have_content("Seller Delivers to Customer on")
        expect(page).to have_content("Friday May 9, 2014 between 7:00AM and 11:00AM")

        expect(page).to have_content(sellers_order.order_number)

        expect(page).to have_content(sellers.name)
        expect(page).to have_content(buyer1.name)

        expect(Dom::Admin::IndividualPackListItem.count).to eql(1)

        line = Dom::Admin::IndividualPackListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content(1)
        expect(line.units).to have_content(sellers_product.unit.singular)
      end

      it "does not show slips for a different seller" do
        expect(page).to have_content("Individual Packing Slips")

        expect(page).to_not have_content(others_order.order_number)

        expect(page).to_not have_content(others.name)
        expect(page).to_not have_content(buyer2.name)
      end
    end
  end
end
