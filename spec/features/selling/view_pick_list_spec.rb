require "spec_helper"

describe "Pick list" do
  let!(:market)                   { create(:market) }
  let!(:seller)                   { create(:organization, :seller, :single_location, markets: [market], name: "First Seller") }
  let!(:seller2)                  { create(:organization, :seller, :single_location, markets: [market], name: "Second Seller") }
  let!(:seller_product)           { create(:product, :sellable, name: "Beans", organization: seller) }
  let!(:seller_product2)          { create(:product, :sellable, name: "Avocado", organization: seller) }
  let!(:delivered_product)        { create(:product, :sellable, organization: seller) }
  let!(:seller2_product)          { create(:product, :sellable, name: "Sprouts", organization: seller2) }

  let!(:friday_delivery_schedule) { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery)          { create(:delivery, delivery_schedule: friday_delivery_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

  let!(:buyer1)                   { create(:organization, :buyer, :single_location, markets: [market], name: "First Buyer") }
  let!(:buyer2)                   { create(:organization, :buyer, :single_location, markets: [market], name: "Second Buyer") }

  let!(:seller_order_item)        { create(:order_item, product: seller_product, quantity: 1)}
  let!(:seller_order_item_prod2)  { create(:order_item, product: seller_product2, quantity: 2) }
  let!(:seller_order)             { create(:order, items: [seller_order_item], organization: buyer1, market: market, delivery: friday_delivery) }
  let!(:seller_order_item2)       { create(:order_item, product: seller_product2, quantity: 1)}
  let!(:seller_order2)            { create(:order, items: [seller_order_item2], organization: buyer1, market: market, delivery: friday_delivery) }
  let!(:delivered_order_item)     { create(:order_item, product: delivered_product, quantity: 1, delivery_status: 'delivered')}
  let!(:delivered_order)          { create(:order, items: [delivered_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

  let!(:seller2_order_item)       { create(:order_item, product: seller2_product, quantity: 2)}
  let!(:seller2_order)            { create(:order, items: [seller2_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

  before do
    Timecop.travel("May 5, 2014")
    switch_to_subdomain(market.subdomain)
    sign_in_as(user)
  end

  after do
    Timecop.return
  end

  context "as a market manager" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    # This should be visible to the market manager
    let!(:seller_no_longer)            { create(:organization, :seller, :single_location, name: "Seller No Longer In Market") }
    let!(:seller_no_longer_product)    { create(:product, :sellable, name: "Onion", organization: seller_no_longer) }
    let!(:seller_no_longer_order_item) { create(:order_item, product: seller_no_longer_product, quantity: 1)}
    let!(:seller_no_longer_order)      { create(:order, items: [seller_no_longer_order_item], organization: buyer1, market: market, delivery: friday_delivery) }

    context "orders for multiple sellers" do
      before do
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick lists in alphabetical order" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")

        seller_pick_list, other_pick_list, no_longer_pick_list, empty = Dom::Admin::PickList.all
        expect(empty).to be_nil

        expect(seller_pick_list.org).to eql("First Seller")
        expect(seller_pick_list.items.count).to eql(2)

        expect(other_pick_list.org).to eql("Second Seller")
        expect(other_pick_list.items.count).to eql(1)

        expect(no_longer_pick_list.org).to eql("Seller No Longer In Market")
        expect(no_longer_pick_list.items.count).to eql(1)

        within(seller_pick_list.node) do
          avocado, beans, empty = Dom::Admin::PickListItem.all
          expect(empty).to be_nil

          expect(avocado.name).to have_content("Avocado")
          expect(avocado.total_sold).to have_content("1")
          expect(avocado.buyer).to have_content("First Buyer")
          expect(avocado.breakdown).to have_content("1")

          expect(beans.name).to have_content("Beans")
          expect(beans.total_sold).to have_content("1")
          expect(beans.buyer).to have_content("First Buyer")
          expect(beans.breakdown).to have_content("1")
        end

        within(other_pick_list.node) do
          sprouts, empty = Dom::Admin::PickListItem.all
          expect(empty).to be_nil

          expect(sprouts.name).to have_content("Sprouts")
          expect(sprouts.total_sold).to have_content("2")
          expect(sprouts.buyer).to have_content("Second Buyer")
          expect(sprouts.breakdown).to have_content("2")
        end

        within(no_longer_pick_list.node) do
          onion, empty = Dom::Admin::PickListItem.all
          expect(empty).to be_nil

          expect(onion.name).to have_content("Onion")
          expect(onion.total_sold).to have_content("1")
          expect(onion.buyer).to have_content("First Buyer")
          expect(onion.breakdown).to have_content("1")
        end
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [seller]) }

    context "before the delivery cutoff" do
      before do
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content("Ordering has not yet closed for this delivery")
        expect(page).to have_content(seller.name)
        expect(page).to_not have_content(seller2.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "after the delivery cutoff" do
      before do
        Timecop.travel("May 9, 2014")
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to_not have_content("Ordering has not yet closed for this delivery")
        expect(page).to have_content(seller.name)
        expect(page).to_not have_content(seller2.name)
      end
    end

    context "single order" do
      before do
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content(seller.name)

        lines = Dom::Admin::PickListItem.all
        expect(lines.count).to eql(2)

        line = Dom::Admin::PickListItem.find_by_name(seller_product.name)
        expect(line.total_sold).to have_content("1")
        expect(line.buyer).to have_content(buyer1.name)
        expect(line.breakdown).to have_content("1")

        expect(page).to_not have_content(seller2_product.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "multiple orders" do
      let!(:order_item2) { create(:order_item, product: seller_product, quantity: 3)}
      let!(:order2)      { create(:order, items: [order_item2], organization: buyer2, market: market, delivery: friday_delivery) }

      before do
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows the pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")
        expect(page).to have_content(seller.name)

        expect(Dom::Admin::PickListItem.count).to eql(2)

        line = Dom::Admin::PickListItem.find_by_name(seller_product.name)
        expect(line.total_sold).to have_content("4")
        expect(line.buyer).to have_content(buyer1.name)
        expect(line.breakdown).to have_content("1")

        expect(page).to_not have_content(seller2_product.name)
      end

      it "does not show delivered items" do
        expect(Dom::Admin::PickListItem.find_by_name(delivered_product.name)).to be_nil
      end
    end

    context "lots" do
      context "single lot" do
        let!(:lot)            { create(:lot, product: seller_product, number: "123", quantity: 10) }
        let!(:order_item_lot) { create(:order_item_lot, order_item: seller_order_item, lot: lot) }

        before do
          visit admin_delivery_tools_pick_list_path(friday_delivery.id)
        end

        it "displays any numbered lots used" do
          line = Dom::Admin::PickListItem.all[1]

          expect(line.name).to have_content(seller_product.name)
          expect(line.breakdown).to have_content("Lot #123: 1")
        end
      end

      context "spanning multiple lots" do
        let!(:lot1)            { create(:lot, product: seller_product, number: "123", quantity: 15)}
        let!(:order_item_lot1) { create(:order_item_lot, order_item: seller_order_item, lot: lot1, quantity: 15) }
        let!(:lot2)            { create(:lot, product: seller_product, number: "456", quantity: 5)}
        let!(:order_item_lot2) { create(:order_item_lot, order_item: seller_order_item, lot: lot2, quantity: 3) }

        before do
          seller_order_item.update(quantity: 18)
          visit admin_delivery_tools_pick_list_path(friday_delivery.id)
        end

        it "shows the pick list" do
          line = Dom::Admin::PickListItem.find_by_name(seller_product.name)
          expect(line.total_sold).to have_content("18")
          expect(line.breakdown).to have_content("Lot #123: 15")
          expect(line.breakdown).to have_content("Lot #456: 3")
        end
      end
    end

    context "managing another market" do
      let!(:market2) { create(:market, managers: [user]) }

      before do
        visit admin_delivery_tools_pick_list_path(friday_delivery.id)
      end

      it "shows only the seller pick list" do
        expect(page).to have_content("Pick List")
        expect(page).to have_content("May 9, 2014 between 7:00AM and 11:00AM")

        seller_pick_list, empty = Dom::Admin::PickList.all
        expect(empty).to be_nil # Should only find 1 list

        expect(seller_pick_list.org).to eql("First Seller")
        expect(seller_pick_list.items.count).to eql(2)

        within(seller_pick_list.node) do
          avocado, beans, empty = Dom::Admin::PickListItem.all
          expect(empty).to be_nil

          expect(avocado.name).to have_content("Avocado")
          expect(avocado.total_sold).to have_content("1")
          expect(avocado.buyer).to have_content("First Buyer")
          expect(avocado.breakdown).to have_content("1")

          expect(beans.name).to have_content("Beans")
          expect(beans.total_sold).to have_content("1")
          expect(beans.buyer).to have_content("First Buyer")
          expect(beans.breakdown).to have_content("1")
        end
      end
    end
  end
end
