require "spec_helper"

describe "Upcoming Deliveries" do
  before do
    Timecop.travel("May 5, 2014")
  end

  let!(:market)  { create(:market) }
  let!(:seller)  { create(:organization, :seller, markets: [market]) }
  let!(:seller2) { create(:organization, :seller, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: seller) }
  let!(:seller2_product) { create(:product, :sellable, organization: seller2) }

  let!(:sunday_delivery_schedule) { create(:delivery_schedule, market: market, day: 0) }
  let!(:sunday_delivery) { create(:delivery, delivery_schedule: sunday_delivery_schedule, deliver_on: Date.parse("May 4, 2014")) }

  let!(:wednesday_delivery_schedule) { create(:delivery_schedule, market: market, day: 3) }
  let!(:wednesday_delivery) { create(:delivery, delivery_schedule: wednesday_delivery_schedule, deliver_on: Date.parse("May 7, 2014")) }

  let!(:thursday_delivery_schedule) { create(:delivery_schedule, market: market, day: 4) }
  let!(:thursday_delivery) { create(:delivery, delivery_schedule: thursday_delivery_schedule, deliver_on: Date.parse("May 8, 2014")) }

  let!(:friday_delivery_schedule) { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_delivery_schedule, deliver_on: Date.parse("May 9, 2014")) }

  after do
    Timecop.return
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [seller]) }

    context "with orders" do
      let!(:order_item_for_seller_product) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:delivered_order_item) { create(:order_item, product: product, quantity: 1, delivery_status: "delivered") }
      let!(:delivered_order) { create(:order, items: [delivered_order_item], organization: seller, market: market, delivery: wednesday_delivery) }

      let!(:other_order_item) { create(:order_item, product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have ordered products for a seller" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(1)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
      end

      it "shows a delivery until 11:59 the day of the delivery" do
        Timecop.travel("May 8, 2014 11:30 PM") do
          visit admin_delivery_tools_path

          expect(page).to have_content("Upcoming Deliveries")

          deliveries = Dom::UpcomingDelivery.all
          expect(deliveries.count).to eql(1)
          expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
        end
      end

      it "does not show orders that have been delivered" do
        expect(page).to have_content("Upcoming Deliveries")
        expect(Dom::UpcomingDelivery.find_by_upcoming_delivery_date("May 7, 2014, 7:00 AM")).to be_nil
      end
    end

    context "shows deliveries only once" do
      let!(:order_item_for_seller_product1) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product1) { create(:order, items: [order_item_for_seller_product1], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:order_item_for_seller_product2) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product2) { create(:order, items: [order_item_for_seller_product2], organization: seller, market: market, delivery: thursday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(1)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
      end
    end

    context "multiple market membership" do
      let!(:other_market) { create(:market, organizations: [seller]) }

      let!(:order_item_for_seller_product) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:other_order_item) { create(:order_item, product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      let!(:friday_delivery_schedule) { create(:delivery_schedule, market: other_market, day: 5) }
      let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_delivery_schedule, deliver_on: Date.parse("May 9, 2014")) }

      let!(:other_market_order_item) { create(:order_item, product: product, quantity: 1) }
      let!(:other_market_order) { create(:order, items: [other_market_order_item], organization: seller, market: other_market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows the the market name with the upcoming delivery" do
        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.map { |d| d.market }).to contain_exactly(market.name, other_market.name)
      end

      it "shows all upcoming deliveries for all markets the user is authorized to view" do
        expect(page).to have_content(market.name)
        expect(page).to have_content(other_market.name)
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Upcoming Deliveries")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

  context "as a market manager" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "with orders" do
      let!(:order_item_for_seller_product) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:other_order_item) { create(:order_item, product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
        expect(deliveries.last.upcoming_delivery_date).to eq("Friday May 9, 2014 7:00 AM")
      end
    end

    context "shows deliveries only once" do
      let!(:order_item_for_seller_product1) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product1) { create(:order, items: [order_item_for_seller_product1], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:order_item_for_seller_product2) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product2) { create(:order, items: [order_item_for_seller_product2], organization: seller, market: market, delivery: thursday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(1)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
      end
    end

    context "multiple market membership" do

      let!(:order_item_for_seller_product) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:other_order_item) { create(:order_item, product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows the the market name with the upcoming delivery" do
        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.first.market).to have_content(market.name)
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Upcoming Deliveries")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

  context "as an admin" do
    let!(:user) { create(:user, :admin) }

    context "without a selected market" do
      let!(:order_item_for_seller_product) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:other_order_item) { create(:order_item, product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      context "multiple markets available" do
        let!(:other_market) { create(:market) }

        before do
          sign_in_as(user)
          visit admin_delivery_tools_path
        end

        it "shows a list of the upcoming deliveries that have orders" do
          expect(page).to have_content("Please Select a Market")
          click_link market.name

          expect(page).to have_content("Upcoming Deliveries")

          deliveries = Dom::UpcomingDelivery.all
          expect(deliveries.count).to eql(2)
          expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
          expect(deliveries.last.upcoming_delivery_date).to eq("Friday May 9, 2014 7:00 AM")
        end
      end

      context "single market available" do
        before do
          sign_in_as(user)
          visit admin_delivery_tools_path
        end

        it "shows a list of the upcoming deliveries that have orders" do
          expect(page).to have_content("Upcoming Deliveries")

          deliveries = Dom::UpcomingDelivery.all
          expect(deliveries.count).to eql(2)
          expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
          expect(deliveries.last.upcoming_delivery_date).to eq("Friday May 9, 2014 7:00 AM")
        end
      end
    end

    context "with orders" do
      let!(:order_item_for_seller_product) { create(:order_item,  product: product, quantity: 1) }
      let!(:order_with_seller_product) { create(:order, items: [order_item_for_seller_product], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:other_order_item) { create(:order_item,  product: seller2_product, quantity: 1) }
      let!(:other_order) { create(:order, items: [other_order_item], organization: seller2, market: market, delivery: friday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
        expect(deliveries.last.upcoming_delivery_date).to eq("Friday May 9, 2014 7:00 AM")
      end
    end

    context "shows deliveries only once" do
      let!(:order_item_for_seller_product1) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product1) { create(:order, items: [order_item_for_seller_product1], organization: seller, market: market, delivery: thursday_delivery) }

      let!(:order_item_for_seller_product2) { create(:order_item, product: product, quantity: 1) }
      let!(:order_with_seller_product2) { create(:order, items: [order_item_for_seller_product2], organization: seller, market: market, delivery: thursday_delivery) }

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Upcoming Deliveries")

        deliveries = Dom::UpcomingDelivery.all
        expect(deliveries.count).to eql(1)
        expect(deliveries.first.upcoming_delivery_date).to eq("Thursday May 8, 2014 7:00 AM")
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Upcoming Deliveries")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

end
