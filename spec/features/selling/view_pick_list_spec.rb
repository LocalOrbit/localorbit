require "spec_helper"

describe "Pick list" do
  let!(:market)                    { create(:market) }
  let!(:sellers)                   { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:others)                    { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:sellers_product)           { create(:product, :sellable, organization: sellers) }
  let!(:delivered_product)         { create(:product, :sellable, organization: sellers) }
  let!(:others_product)            { create(:product, :sellable, organization: others) }

  let!(:friday_schedule_schedule)  { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery)           { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

  let!(:buyer1)                    { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:buyer2)                    { create(:organization, :buyer, :single_location, markets: [market]) }

  let!(:sellers_order_item)        { create(:order_item, product: sellers_product, quantity: 1)}
  let!(:delivered_order_item)      { create(:order_item, product: delivered_product, quantity: 1, delivery_status: 'delivered')}
  let!(:sellers_order)             { create(:order, items: [delivered_order_item, sellers_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

  let!(:others_order_item)         { create(:order_item, product: others_product, quantity: 2)}
  let!(:others_order)              { create(:order, items: [others_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "as a market manager" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "orders for multiple sellers" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)

        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content(sellers.name)
      end

      it "shows the pick lists" do
        lines = Dom::Admin::PickListItem.all
        expect(lines.count).to eql(2)

        line = Dom::Admin::PickListItem.find_by_name(sellers_product.name)
        expect(line.name).to have_content(sellers_product.name)
        expect(line.total_sold).to have_content("1")
        expect(line.buyer).to have_content(buyer1.name)
        expect(line.breakdown).to have_content("1")

        expect(page).to have_content(others.name)

        line = Dom::Admin::PickListItem.find_by_name(others_product.name)
        expect(line.name).to have_content(others_product.name)
        expect(line.total_sold).to have_content("2")
        expect(line.buyer).to have_content(buyer2.name)
        expect(line.breakdown).to have_content("2")
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [sellers]) }

    context "before the delivery cutoff" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content("Ordering has not yet closed for this delivery")
        expect(page).to have_content(sellers.name)
        expect(page).to_not have_content(others.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "after the delivery cutoff" do
      before do
        Timecop.travel("May 9, 2014")
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to_not have_content("Ordering has not yet closed for this delivery")
        expect(page).to have_content(sellers.name)
        expect(page).to_not have_content(others.name)
      end
    end

    context "single order" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)

        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content(sellers.name)
      end

      it "shows the pick list" do
        lines = Dom::Admin::PickListItem.all
        expect(lines.count).to eql(1)

        line = Dom::Admin::PickListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content("1")
        expect(line.buyer).to have_content(buyer1.name)
        expect(line.breakdown).to have_content("1")

        expect(page).to_not have_content(others_product.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "multiple orders" do
      let!(:order_item2) { create(:order_item, product: sellers_product, quantity: 1)}
      let!(:order2)      { create(:order, items: [order_item2], organization: buyer2, market: market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)

        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content(sellers.name)
      end

      it "shows the pick list", js: true do
        expect(Dom::Admin::PickListItem.count).to eql(1)

        line = Dom::Admin::PickListItem.find_by_name(sellers_product.name)
        expect(line.total_sold).to have_content("2")
        expect(line.buyer).to have_content(buyer2.name)
        expect(line.breakdown).to have_content("1")

        expect(page).to_not have_content(others_product.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "lots" do
      context "single lot" do
        let!(:lot)        { create(:lot, product: sellers_product, number: "123", quantity: 10) }
        let!(:order_item_lot) { create(:order_item_lot, order_item: sellers_order_item, lot: lot) }

        before do
          lot.number = "123"
          switch_to_subdomain(market.subdomain)
          sign_in_as(user)
          visit admin_delivery_tools_pick_list_path(friday_delivery.id)
        end

        it "displays any numbered lots used" do
          line = Dom::Admin::PickListItem.first

          expect(line.name).to have_content(sellers_product.name)
          expect(line.breakdown).to have_content("Lot #123: 1")
        end
      end

      context "spanning multiple lots" do
        let!(:lot1)       { create(:lot, product: sellers_product, number: "123", quantity: 15)}
        let!(:order_item_lot1) { create(:order_item_lot, order_item: sellers_order_item, lot: lot1, quantity: 15) }
        let!(:lot2)       { create(:lot, product: sellers_product, number: "456", quantity: 5)}
        let!(:order_item_lot2) { create(:order_item_lot, order_item: sellers_order_item, lot: lot2, quantity: 3) }

        before do
          sellers_order_item.update(quantity: 18)
          switch_to_subdomain(market.subdomain)
          sign_in_as(user)
          visit admin_delivery_tools_pick_list_path(friday_delivery.id)
        end

        it "shows the pick list" do
          line = Dom::Admin::PickListItem.find_by_name(sellers_product.name)
          expect(line.total_sold).to have_content("18")
          expect(line.breakdown).to have_content("Lot #123: 15")
          expect(line.breakdown).to have_content("Lot #456: 3")
        end
      end
    end
  end


end
