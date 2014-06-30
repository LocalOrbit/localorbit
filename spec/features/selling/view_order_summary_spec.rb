require "spec_helper"

describe "Order summary" do
  let!(:user) { create(:user, organizations: [sellers]) }
  let!(:admin) { create(:user, :admin) }
  let!(:market_manager) { create(:user) }
  let!(:market)  { create(:market, :with_addresses, managers:[market_manager]) }
  let!(:sellers) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:others) { create(:organization, :seller, :single_location, markets: [market]) }
  let!(:sellers_product1) { create(:product, :sellable, organization: sellers) }
  let!(:sellers_product2) { create(:product, :sellable, organization: sellers) }
  let!(:sellers_product3) { create(:product, :sellable, organization: sellers) }
  let!(:others_product) { create(:product, :sellable, organization: others) }

  let!(:buyer1) { create(:organization, :buyer, :single_location, markets: [market]) }
  let!(:buyer2) { create(:organization, :buyer, :single_location, markets: [market]) }

  let!(:friday_schedule_schedule) { create(:delivery_schedule, :buyer_pickup, market: market, day: 5) }
  let!(:friday_delivery) { create(:delivery, delivery_schedule: friday_schedule_schedule, deliver_on: Date.parse("May 9, 2014"), cutoff_time: Date.parse("May 8, 2014"))}

  let!(:sellers_order1_item1) { create(:order_item, product: sellers_product1, quantity: 3)}
  let!(:sellers_order1_item2) { create(:order_item, product: sellers_product3, quantity: 9)}
  let!(:sellers_order1)      { create(:order, items: [sellers_order1_item1, sellers_order1_item2], organization: buyer1, market: market, delivery: friday_delivery) }

  let!(:sellers_order2_item) { create(:order_item, product: sellers_product2, quantity: 6)}
  let!(:sellers_order2)      { create(:order, items:[sellers_order2_item], organization: buyer2, market: market, delivery: friday_delivery) }

  let!(:others_order_item) { create(:order_item, product: others_product, quantity: 2)}
  let!(:others_order)      { create(:order, items: [others_order_item], organization: buyer2, market: market, delivery: friday_delivery) }

  before do
    Timecop.travel("May 5, 2014")
  end

  after do
    Timecop.return
  end

  context "as a seller" do
    it "can be navigated to" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)

      click_link "Order Summary"
      expect(page).to have_content("Order Summary")
    end

    it "displays an order summary for the delivery" do
      switch_to_subdomain(market.subdomain)
      sign_in_as(user)
      visit admin_delivery_tools_order_summary_path(friday_delivery.id)

      expect(page).to have_content("Order Summary")

      expect(page).to have_content(sellers.name)
      expect(page).to have_content(sellers.shipping_location.address)
      expect(page).to have_content(sellers.shipping_location.phone)

      expect(page).to have_content(buyer1.name)
      expect(page).to have_content(sellers_order1.order_number)
      expect(page).to have_content(sellers_order1_item1.name)
      expect(page).to have_content(sellers_order1_item2.name)

      expect(page).to have_content(buyer2.name)
      expect(page).to have_content(sellers_order2.order_number)
      expect(page).to have_content(sellers_order2_item.name)
      expect(page).not_to have_content(others_order.order_number)
      expect(page).not_to have_content(others_order_item.name)
    end
  end

  context "display  a list of order summaries for a delivery" do
    context "as a market manager" do
      it "can be navigated to" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(market_manager)
        navigate_to_order_summary
      end

      it "lists order summary for the market" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(market_manager)
        visit admin_delivery_tools_order_summary_path(friday_delivery.id)
        see_orders_for_entire_market
      end

      it "includes items from deleted organizations" do
        MarketOrganization.where(organization_id: sellers.id, market_id: market.id).soft_delete
        switch_to_subdomain(market.subdomain)
        sign_in_as(market_manager)
        navigate_to_order_summary
        see_orders_for_entire_market
      end
    end

    context "as an admin" do
      it "can be navigated to" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(admin)
        navigate_to_order_summary
      end

      it "lists order summary for the market" do
        switch_to_subdomain(market.subdomain)
        sign_in_as(admin)
        visit admin_delivery_tools_order_summary_path(friday_delivery.id)
        see_orders_for_entire_market
      end
    end

    def navigate_to_order_summary
      click_link "Orders & Delivery"
      click_link "Upcoming Deliveries"
      click_link "Order Summary"

      expect(page).to have_content("Order Summary")
    end

    def see_orders_for_entire_market
      expect(page).to have_content("Order Summary")

      expect(page).to have_content(sellers.name)
      expect(page).to have_content(sellers.shipping_location.address)
      expect(page).to have_content(sellers.shipping_location.phone)

      expect(page).to have_content(buyer1.name)
      expect(page).to have_content(sellers_order1.order_number)
      expect(page).to have_content(sellers_order1_item1.name)
      expect(page).to have_content(sellers_order1_item2.name)

      expect(page).to have_content(buyer2.name)
      expect(page).to have_content(sellers_order2.order_number)
      expect(page).to have_content(sellers_order2_item.name)

      expect(page).to have_content(others.name)
      expect(page).to have_content(others.shipping_location.address)
      expect(page).to have_content(others.shipping_location.phone)

      expect(page).to have_content(others_order.order_number)
      expect(page).to have_content(others_order_item.name)
    end
  end
end
