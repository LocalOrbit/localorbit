require "spec_helper"

describe "Upcoming Deliveries" do
  let!(:market)  { create(:market) }
  let!(:sellers) { create(:organization, :seller, markets: [market]) }
  let!(:others)  { create(:organization, :seller, markets: [market]) }
  let!(:product) { create(:product, :sellable, organization: sellers) }
  let!(:others_product) { create(:product, :sellable, organization: others)}

  let!(:monday_delivery_schedule) { create(:delivery_schedule, market: market, day: 0) }
  let!(:monday_delivery) { create(:delivery, delivery_schedule: monday_delivery_schedule, deliver_on: Date.parse("May 4, 2014")) }

  let!(:wednesday_delivery_schedule) { create(:delivery_schedule, market: market, day: 4) }
  let!(:wednesday_delivery) { create(:delivery, delivery_schedule: wednesday_delivery_schedule, deliver_on: Date.parse("May 7, 2014")) }

  let!(:thursday_delivery_schedule) { create(:delivery_schedule, market: market, day: 4) }
  let!(:thursday_delivery) { create(:delivery, delivery_schedule: thursday_delivery_schedule, deliver_on: Date.parse("May 8, 2014")) }

  let!(:friday_delivery_schedule) { create(:delivery_schedule, market: market, day: 5) }
  let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_delivery_schedule, deliver_on: Date.parse("May 9, 2014")) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "as a seller" do
    let!(:user) { create(:user, organizations: [sellers]) }

    context "with orders" do
      let!(:order_with_seller_product) { create(:order, organization: sellers, market: market, delivery: thursday_delivery) }
      let!(:order_item_for_seller_product) { create(:order_item, order: order_with_seller_product, product: product, quantity: 1)}

      let!(:other_order) { create(:order, organization: others, market: market, delivery: friday_delivery) }
      let!(:other_order_item) { create(:order_item, order: other_order, product: others_product, quantity: 1)}

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have ordered products for a seller" do
        expect(page).to have_content("Delivery Tools")

        deliveries = Dom::Admin::UpcomingDelivery.all
        expect(deliveries.count).to eql(1)
        expect(deliveries.first.node).to have_content("May 8, 2014")
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Delivery Tools")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

  context "as a market manager" do
    let!(:user) { create(:user, :market_manager, managed_markets: [market]) }

    context "with orders" do
      let!(:order_with_seller_product) { create(:order, organization: sellers, market: market, delivery: thursday_delivery) }
      let!(:order_item_for_seller_product) { create(:order_item, order: order_with_seller_product, product: product, quantity: 1)}

      let!(:other_order) { create(:order, organization: others, market: market, delivery: friday_delivery) }
      let!(:other_order_item) { create(:order_item, order: other_order, product: others_product, quantity: 1)}

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Delivery Tools")

        deliveries = Dom::Admin::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.first.node).to have_content("May 8, 2014")
        expect(deliveries.last.node).to have_content("May 9, 2014")
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Delivery Tools")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

  context "as an admin" do
    let!(:user) { create(:user, :admin) }

    context "with orders" do
      let!(:order_with_seller_product) { create(:order, organization: sellers, market: market, delivery: thursday_delivery) }
      let!(:order_item_for_seller_product) { create(:order_item, order: order_with_seller_product, product: product, quantity: 1)}

      let!(:other_order) { create(:order, organization: others, market: market, delivery: friday_delivery) }
      let!(:other_order_item) { create(:order_item, order: other_order, product: others_product, quantity: 1)}

      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a list of the upcoming deliveries that have orders" do
        expect(page).to have_content("Delivery Tools")

        deliveries = Dom::Admin::UpcomingDelivery.all
        expect(deliveries.count).to eql(2)
        expect(deliveries.first.node).to have_content("May 8, 2014")
        expect(deliveries.last.node).to have_content("May 9, 2014")
      end
    end

    context "without orders" do
      before do
        switch_to_subdomain(market.subdomain)
        sign_in_as(user)
        visit admin_delivery_tools_path
      end

      it "shows a message when there are no upcoming deliveries for the seller" do
        expect(page).to have_content("Delivery Tools")
        expect(page).to have_content("You currently have no upcoming deliveries.")
      end
    end
  end

end
